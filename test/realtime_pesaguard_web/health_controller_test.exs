defmodule RealtimePesaguardWeb.HealthControllerTest do
  use ExUnit.Case, async: true

  import Plug.Test

  test "liveness reports the process is responding" do
    conn =
      conn(:get, "/health/live")
      |> RealtimePesaguardWeb.Router.call(RealtimePesaguardWeb.Router.init([]))

    assert conn.status == 200
    assert Jason.decode!(conn.resp_body)["status"] == "ok"
  end

  test "readiness stays unavailable until required integrations are implemented" do
    conn =
      conn(:get, "/health/ready")
      |> RealtimePesaguardWeb.Router.call(RealtimePesaguardWeb.Router.init([]))

    assert conn.status == 503
    assert Jason.decode!(conn.resp_body)["status"] == "not_ready"
  end
end
