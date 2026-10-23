defmodule RealtimePesaguard.Accounts.SocketSessionMonitor do
  @moduledoc """
  Periodically revalidates connected socket credentials against the canonical API.
  Invalid credentials or an unavailable verifier cause the associated socket ID
  to be disconnected. Raw tokens are held in memory only and are never logged.
  """

  use GenServer

  alias RealtimePesaguard.Accounts.TokenVerifier

  @revalidate_interval_ms 60_000
  @task_timeout_ms 4_000
  @max_concurrency 10

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec register(binary(), binary(), pid()) :: :ok | {:error, term()}
  def register(token, subject, pid)
      when is_binary(token) and is_binary(subject) and is_pid(pid) do
    GenServer.call(__MODULE__, {:register, token, subject, pid})
  catch
    :exit, reason -> {:error, reason}
  end

  @impl true
  def init(_opts) do
    Process.send_after(self(), :revalidate, @revalidate_interval_ms)
    {:ok, %{sessions: %{}}}
  end

  @impl true
  def handle_call({:register, token, subject, pid}, _from, state) do
    state = remove_session(state, pid)
    monitor_ref = Process.monitor(pid)
    session = %{token: token, subject: subject, monitor_ref: monitor_ref}
    {:reply, :ok, put_in(state, [:sessions, pid], session)}
  end

  @impl true
  def handle_info({:DOWN, monitor_ref, :process, pid, _reason}, state) do
    case get_in(state, [:sessions, pid]) do
      %{monitor_ref: ^monitor_ref} -> {:noreply, remove_session(state, pid)}
      _ -> {:noreply, state}
    end
  end

  def handle_info(:revalidate, state) do
    sessions =
      state.sessions
      |> Enum.map(fn {pid, session} -> {pid, session.token, session.subject} end)

    results =
      sessions
      |> Task.async_stream(
        fn {pid, token, subject} ->
          case TokenVerifier.verify(token) do
            {:ok, %{"sub" => ^subject}} -> :valid
            _ -> :invalid
          end
        end,
        max_concurrency: @max_concurrency,
        timeout: @task_timeout_ms,
        on_timeout: :kill_task,
        ordered: true
      )
      |> Enum.zip(sessions)
      |> Enum.map(fn
        {{:ok, :valid}, {pid, _token, _subject}} -> {pid, :valid}
        {_failed_or_invalid, {pid, _token, _subject}} -> {pid, :invalid}
      end)

    invalid_pids =
      Enum.flat_map(results, fn
        {pid, :invalid} -> [pid]
        _ -> []
      end)

    Enum.each(invalid_pids, fn pid ->
      case get_in(state, [:sessions, pid]) do
        %{subject: subject} ->
          # Phoenix's socket ID is subject-scoped; disconnecting it revokes all
          # active sockets for that identity, which is intentionally fail-closed.
          RealtimePesaguardWeb.Endpoint.broadcast("user_socket:#{subject}", "disconnect", %{})

        _ ->
          :ok
      end
    end)

    state = Enum.reduce(invalid_pids, state, &remove_session(&2, &1))
    Process.send_after(self(), :revalidate, @revalidate_interval_ms)
    {:noreply, state}
  end

  defp remove_session(state, pid) do
    case get_in(state, [:sessions, pid]) do
      %{monitor_ref: monitor_ref} ->
        Process.demonitor(monitor_ref, [:flush])
        update_in(state, [:sessions], &Map.delete(&1, pid))

      _ ->
        state
    end
  end
end
