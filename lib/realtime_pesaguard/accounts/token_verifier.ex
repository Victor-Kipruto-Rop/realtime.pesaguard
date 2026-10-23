defmodule RealtimePesaguard.Accounts.TokenVerifier do
  @moduledoc """
  Adapter boundary for validating canonical PesaGuard access tokens.

  TODO: integrate the actual issuer/JWKS or shared verification library. Validate
  signature, issuer, audience, expiry, and required tenant/role claims. Never decode
  a JWT and treat the decoded claims as trusted without verifying its signature.
  """

  @callback verify(binary()) :: {:ok, map()} | {:error, atom()}

  def verify(_token), do: {:error, :identity_verifier_not_configured}
end
