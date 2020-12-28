defmodule ExVatcheck do
  @moduledoc """
  ExVatcheck is a library for validating VAT identification numbers using the
  [VIES service](http://ec.europa.eu/taxation_customs/vies/). Because the VIES
  service is not always reliable, and is frequently unavailable, ExVatcheck
  falls back to Regex in the case when the service can't be reached.
  """

  alias ExVatcheck.{Countries, VAT, Client}

  @spec check(binary) :: VAT.t()
  @doc ~S"""
  Validates a given VAT identification number using the VIES service.

  Returns an `ExVatcheck.VAT.t()` struct.
  """
  def check(vat) do
    normalized_vat = VAT.normalize(vat)

    if Countries.valid_format?(normalized_vat) do
      validate(normalized_vat)
    else
      %VAT{}
    end
  end

  @spec validate(binary) :: VAT.t()
  defp validate(<<country::binary-size(2), number::binary>>) do
    with {:ok, client} <- Client.new(country),
         {:ok, response} <- Client.check_vat(client, country, number) do
      %VAT{
        valid: response.valid,
        exists: response.valid,
        vies_available: true,
        vies_response: response
      }
    else
      {:error, error} ->
        %VAT{
          valid: true,
          vies_response: %{error: error}
        }
    end
  end
end
