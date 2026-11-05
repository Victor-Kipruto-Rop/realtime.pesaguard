defmodule RealtimePesaguard.Accounts.BackendAuthClientTest do
  use ExUnit.Case, async: false

  alias RealtimePesaguard.Accounts.BackendAuthClient

  setup do
    previous_url = Application.get_env(:realtime_pesaguard, :auth_validation_url)
    previous_environment = System.get_env("PESAGUARD_ENVIRONMENT")

    on_exit(fn ->
      if is_nil(previous_url) do
        Application.delete_env(:realtime_pesaguard, :auth_validation_url)
      else
        Application.put_env(:realtime_pesaguard, :auth_validation_url, previous_url)
      end

      if is_nil(previous_environment) do
        System.delete_env("PESAGUARD_ENVIRONMENT")
      else
        System.put_env("PESAGUARD_ENVIRONMENT", previous_environment)
      end
    end)

    :ok
  end

  test "allows the canonical API Docker DNS name over HTTP only in development" do
    Application.put_env(
      :realtime_pesaguard,
      :auth_validation_url,
      "http://dashboard_api:5001/auth/verify"
    )

    System.put_env("PESAGUARD_ENVIRONMENT", "development")

    assert BackendAuthClient.configured?()
  end

  test "rejects external plaintext HTTP even in development" do
    Application.put_env(
      :realtime_pesaguard,
      :auth_validation_url,
      "http://api.example.test/auth/verify"
    )

    System.put_env("PESAGUARD_ENVIRONMENT", "development")

    refute BackendAuthClient.configured?()
  end

  test "rejects loopback plaintext HTTP outside development and test" do
    Application.put_env(
      :realtime_pesaguard,
      :auth_validation_url,
      "http://dashboard_api:5001/auth/verify"
    )

    System.put_env("PESAGUARD_ENVIRONMENT", "production")

    refute BackendAuthClient.configured?()
  end

  test "rejects noncanonical paths, query strings and URL userinfo" do
    System.put_env("PESAGUARD_ENVIRONMENT", "development")

    for url <- [
          "http://dashboard_api:5001/other",
          "http://dashboard_api:5001/auth/verify?debug=true",
          "http://user:password@dashboard_api:5001/auth/verify"
        ] do
      Application.put_env(:realtime_pesaguard, :auth_validation_url, url)
      refute BackendAuthClient.configured?()
    end
  end

  test "continues to accept the canonical HTTPS verifier in hosted environments" do
    Application.put_env(
      :realtime_pesaguard,
      :auth_validation_url,
      "https://api.pesaguard.co.ke/auth/verify"
    )

    System.put_env("PESAGUARD_ENVIRONMENT", "production")

    assert BackendAuthClient.configured?()
  end
end
