defmodule RealtimePesaguard.Security.RateLimiterTest do
  use ExUnit.Case, async: true

  alias RealtimePesaguard.Security.RateLimiter

  test "allows only the configured number of actions in a fixed window" do
    key = "rate-limit-test-#{System.unique_integer([:positive])}"

    assert RateLimiter.allow?(:test_scope, key, 2, 60_000)
    assert RateLimiter.allow?(:test_scope, key, 2, 60_000)
    refute RateLimiter.allow?(:test_scope, key, 2, 60_000)
  end

  test "extracts IPv4 peer addresses without trusting forwarded headers" do
    assert RateLimiter.client_ip(%{peer_data: %{address: {192, 0, 2, 5}}}) == "192.0.2.5"
    assert RateLimiter.client_ip(%{}) == nil
  end
end
