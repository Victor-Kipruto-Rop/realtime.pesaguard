defmodule RealtimePesaguard.Events.IdempotencyGuard do
  @moduledoc """
  Node-local duplicate suppression for internal event delivery.

  This guard reduces duplicate fan-out during retries handled by one running
  node. It is not durable or distributed; production delivery must additionally
  use a shared durable idempotency store before claiming cross-node guarantees.
  """

  use GenServer

  @ttl_ms 600_000
  @max_entries 50_000
  @sweep_ms 60_000

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def claim(event_id, tenant_id) when is_binary(event_id) and is_binary(tenant_id) do
    GenServer.call(__MODULE__, {:claim, event_id, tenant_id})
  catch
    :exit, _reason -> {:error, :unavailable}
  end

  def complete(event_id, tenant_id) do
    GenServer.call(__MODULE__, {:complete, event_id, tenant_id})
  catch
    :exit, _reason -> {:error, :unavailable}
  end

  def release(event_id, tenant_id) do
    GenServer.call(__MODULE__, {:release, event_id, tenant_id})
  catch
    :exit, _reason -> {:error, :unavailable}
  end

  @impl true
  def init(_opts) do
    Process.send_after(self(), :sweep, @sweep_ms)
    {:ok, %{}}
  end

  @impl true
  def handle_call({:claim, event_id, tenant_id}, _from, state) do
    now = System.monotonic_time(:millisecond)
    state = purge_expired(state, now)

    reply =
      case Map.get(state, event_id) do
        nil when map_size(state) >= @max_entries ->
          {:error, :saturated}

        nil ->
          :ok

        %{tenant_id: ^tenant_id} ->
          {:error, :duplicate}

        _other ->
          {:error, :event_id_conflict}
      end

    next_state =
      if reply == :ok do
        Map.put(state, event_id, %{
          tenant_id: tenant_id,
          status: :pending,
          expires_at: now + @ttl_ms
        })
      else
        state
      end

    {:reply, reply, next_state}
  end

  def handle_call({:complete, event_id, tenant_id}, _from, state) do
    case Map.get(state, event_id) do
      %{tenant_id: ^tenant_id, status: :pending} = entry ->
        updated = %{entry | status: :delivered, expires_at: System.monotonic_time(:millisecond) + @ttl_ms}
        {:reply, :ok, Map.put(state, event_id, updated)}

      %{tenant_id: ^tenant_id, status: :delivered} ->
        {:reply, :ok, state}

      _ ->
        {:reply, {:error, :not_claimed}, state}
    end
  end

  def handle_call({:release, event_id, tenant_id}, _from, state) do
    next_state =
      case Map.get(state, event_id) do
        %{tenant_id: ^tenant_id, status: :pending} -> Map.delete(state, event_id)
        _ -> state
      end

    {:reply, :ok, next_state}
  end

  @impl true
  def handle_info(:sweep, state) do
    Process.send_after(self(), :sweep, @sweep_ms)
    {:noreply, purge_expired(state, System.monotonic_time(:millisecond))}
  end

  defp purge_expired(state, now) do
    Map.reject(state, fn {_event_id, entry} -> entry.expires_at <= now end)
  end
end
