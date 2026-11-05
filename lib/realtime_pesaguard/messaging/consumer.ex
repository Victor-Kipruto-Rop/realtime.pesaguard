defmodule RealtimePesaguard.Messaging.Consumer do
  @moduledoc """
  Supervised Redpanda/Kafka consumer for the explicitly approved browser event topics.

  The consumer starts disconnected and retries broker connection without taking
  the Phoenix endpoint down. Readiness is true only after its consumer group starts.
  """
  use GenServer
  require Logger

  @client_id :pesaguard_realtime_kafka
  @retry_ms 5_000
  @health_check_ms 10_000

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def configured? do
    case Process.whereis(__MODULE__) do
      nil -> false
      _pid ->
        try do
          GenServer.call(__MODULE__, :ready, 1_000)
        catch
          :exit, _ -> false
        end
    end
  end

  @impl true
  def init(_opts) do
    Process.flag(:trap_exit, true)
    enabled? = Application.get_env(:realtime_pesaguard, :event_consumer_enabled, false)
    if enabled?, do: send(self(), :connect)
    {:ok, %{enabled?: enabled?, client_started?: false, subscriber: nil, ready?: false}}
  end

  @impl true
  def handle_call(:ready, _from, state), do: {:reply, state.ready?, state}

  @impl true
  def handle_info(:connect, %{enabled?: false} = state), do: {:noreply, state}

  def handle_info(:connect, state) do
    with {:ok, endpoints} <- broker_endpoints(),
         :ok <- start_client(state.client_started?, endpoints),
         :ok <- ensure_topics_available(),
         {:ok, subscriber} <- start_subscriber() do
      Logger.info("Realtime event consumer connected to configured Redpanda topics")
      Process.send_after(self(), :health_check, @health_check_ms)
      {:noreply, %{state | client_started?: true, subscriber: subscriber, ready?: true}}
    else
      {:error, reason} ->
        Logger.warning("Realtime event consumer unavailable; retrying: #{inspect(reason)}")
        Process.send_after(self(), :connect, @retry_ms)
        {:noreply, %{state | ready?: false}}
    end
  end

  def handle_info(:health_check, %{subscriber: subscriber} = state) when is_pid(subscriber) do
    ready? = ensure_topics_available() == :ok
    if not ready?, do: Logger.warning("Realtime broker topic health check failed")
    Process.send_after(self(), :health_check, @health_check_ms)
    {:noreply, %{state | ready?: ready?}}
  end

  def handle_info(:health_check, state), do: {:noreply, state}

  def handle_info({:EXIT, subscriber, reason}, %{subscriber: subscriber} = state) do
    Logger.warning("Realtime consumer group stopped; reconnecting: #{inspect(reason)}")
    Process.send_after(self(), :connect, @retry_ms)
    {:noreply, %{state | subscriber: nil, ready?: false}}
  end

  def handle_info(_message, state), do: {:noreply, state}

  @impl true
  def terminate(_reason, %{client_started?: true}) do
    :brod.stop_client(@client_id)
    :ok
  catch
    _, _ -> :ok
  end

  def terminate(_reason, _state), do: :ok

  defp start_client(true, _endpoints), do: :ok

  defp start_client(false, endpoints) do
    :brod.start_client(endpoints, @client_id, allow_topic_auto_creation: false)
  end

  defp broker_endpoints do
    brokers = Application.get_env(:realtime_pesaguard, :kafka_brokers, [])

    endpoints =
      brokers
      |> Enum.map(&parse_endpoint/1)
      |> Enum.reject(&is_nil/1)

    if endpoints == [], do: {:error, :kafka_brokers_not_configured}, else: {:ok, endpoints}
  end

  defp parse_endpoint(value) when is_binary(value) do
    case String.split(String.trim(value), ":", parts: 2) do
      [host, port] when host != "" ->
        case Integer.parse(port) do
          {port_number, ""} when port_number in 1..65_535 ->
            {String.to_charlist(host), port_number}
          _ -> nil
        end
      _ -> nil
    end
  end

  defp parse_endpoint(_), do: nil

  defp ensure_topics_available do
    topics =
      Application.get_env(
        :realtime_pesaguard,
        :kafka_event_topics,
        [
          "pesaguard.transactions.failed",
          "pesaguard.transactions.rejected",
          "pesaguard.fraud.analysis"
        ]
      )

    Enum.reduce_while(topics, :ok, fn topic, :ok ->
      case :brod.get_partitions_count_safe(@client_id, topic) do
        {:ok, count} when count > 0 -> {:cont, :ok}
        {:error, reason} -> {:halt, {:error, {:topic_unavailable, topic, reason}}}
        _ -> {:halt, {:error, {:topic_unavailable, topic}}}
      end
    end)
  end

  defp start_subscriber do
    group_id =
      Application.get_env(
        :realtime_pesaguard,
        :kafka_consumer_group,
        "pesaguard-realtime-gateway-v1"
      )

    topics =
      Application.get_env(
        :realtime_pesaguard,
        :kafka_event_topics,
        [
          "pesaguard.transactions.failed",
          "pesaguard.transactions.rejected",
          "pesaguard.fraud.analysis"
        ]
      )
      

    :brod.start_link_group_subscriber(
      @client_id,
      group_id,
      topics,
      [offset_commit_policy: :commit_to_kafka_v2, offset_commit_interval_seconds: 5],
      [begin_offset: :latest, prefetch_count: 0, prefetch_bytes: 0, max_bytes: 1_048_576],
      RealtimePesaguard.Messaging.EventHandler,
      %{}
    )
  end
end
