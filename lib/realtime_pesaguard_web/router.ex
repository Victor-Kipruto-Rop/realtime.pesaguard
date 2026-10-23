defmodule RealtimePesaguardWeb.Router do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RealtimePesaguardWeb do
    pipe_through :api
    get "/health/live", HealthController, :live
    get "/health/ready", HealthController, :ready
    post "/internal/events", InternalEventsController, :create
  end
end
