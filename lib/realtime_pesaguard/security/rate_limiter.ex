defmodule RealtimePesaguard.Security.RateLimiter do
  @moduledoc """
  Small node-local fixed-window limiter for socket handshakes and channel joins.

  This is an abuse-control layer, not a distributed quota system. Production
  deployments with multiple gateway instances should also enforce edge-level
  connection limits at the load balancer or proxy.
  """

  use GenServer

  @table :realtime_pesaguard_rate_limits
  @window_ms 60_000
  @sweep_ms 60_000
  @max_entries 50_000

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Allows at most the configured number of actions for a scope/key in each window.
  Fails closed if the limiter is not running or its table is saturated.
  """
  @spec allow?(atom(), term(), pos_integer(), pos_integer()) :: boolean()
  def allow?(scope, key, limit, window_ms)
      when is_atom(scope) and is_integer(limit) and limit > 0 and
             is_integer(window_ms) and window_ms > 0 do
    now = System.monotonic_time(:millisecond)
    window = div(now, window_ms)
    bucket = {scope, key, window}

    try do
      if :ets.info(@table, :size) >= @max_entries and
           :ets.lookup(@table, bucket) == [] do
        false
      else
        :ets.update_counter(@table, bucket, {2, 1}, {bucket, 0}) <= limit
      end
    rescue
      ArgumentError -> false
    end
  end

  def client_ip(%{peer_data: %{address: address}}) do
    case :inet.ntoa(address) do
      {:error, _} -> nil
      ip -> List.to_string(ip)
    end
  rescue
    _ -> nil
  end

  def client_ip(_), do: nil

  @impl true
  def init(_opts) do
    table =
      :ets.new(@table, [
        :named_table,
        :set,
        :public,
        read_concurrency: true,
        write_concurrency: true
      ])

    Process.send_after(self(), :sweep, @sweep_ms)
    {:ok, %{table: table}}
  end

  @impl true
  def handle_info(:sweep, state) do
    current_window = div(System.monotonic_time(:millisecond), @window_ms)
    cutoff = current_window - 2

    :ets.select_delete(@table, [
      {{{:"$1", :"$2", :"$3"}, :"$4"}, [{:<, :"$3", cutoff}], [true]}
    ])

    Process.send_after(self(), :sweep, @sweep_ms)
    {:noreply, state}
  end
end
