defmodule RealtimePesaguard.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Finch, name: RealtimePesaguard.Finch},
      RealtimePesaguard.Security.RateLimiter,
      RealtimePesaguard.Accounts.SocketSessionMonitor,
      {Phoenix.PubSub, name: RealtimePesaguard.PubSub},
      RealtimePesaguardWeb.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: RealtimePesaguard.Supervisor)
  end

  @impl true
  def config_change(changed, _new, removed) do
    RealtimePesaguardWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
