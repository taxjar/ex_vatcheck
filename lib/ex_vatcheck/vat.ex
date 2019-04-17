defmodule ExVatcheck.VAT do
  @moduledoc """
  The ExVatcheck.VAT module provides a struct that encapsulates the properties of
  a VAT identification number after validation.
  """

  defstruct exists: false,
            valid: false,
            vies_available: false,
            vies_response: %{}

  @type t :: %__MODULE__{
          exists: boolean,
          valid: boolean,
          vies_available: boolean,
          vies_response: map
        }

  @non_alphanumerics ~r/[^a-zA-Z\d]+/u

  @spec normalize(binary) :: binary
  def normalize(vat) do
    vat
    |> String.upcase()
    |> String.replace(@non_alphanumerics, "")
  end
end
