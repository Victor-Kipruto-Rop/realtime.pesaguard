defmodule RealtimePesaguard.Tenants.AccessPolicy do
  @moduledoc "Default-deny tenant authorization policy."

  def authorize_join(%{"tenant_id" => tenant_id}, requested_tenant_id)
      when is_binary(tenant_id) and is_binary(requested_tenant_id) do
    if secure_equal(tenant_id, requested_tenant_id), do: :ok, else: {:error, :tenant_forbidden}
  end

  def authorize_join(_, _), do: {:error, :unauthorized}

  defp secure_equal(a, b) when byte_size(a) == byte_size(b), do: Plug.Crypto.secure_compare(a, b)
  defp secure_equal(_, _), do: false
end
