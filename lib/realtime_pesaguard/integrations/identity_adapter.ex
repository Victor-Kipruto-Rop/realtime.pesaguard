defmodule RealtimePesaguard.Integrations.IdentityAdapter do
  @moduledoc "Boundary for the canonical PesaGuard identity/token verifier."

  def verify_token(token), do: RealtimePesaguard.Accounts.TokenVerifier.verify(token)
end
