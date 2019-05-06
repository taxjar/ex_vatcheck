defmodule ExVatcheck.Countries do
  @moduledoc """
  A module for checking to see whether or not a VAT matches one of the expected
  patterns for EU countries. Countries handled include:

    AT: Austria
    BE: Belgium
    BG: Bulgaria
    CY: Cyprus
    CZ: Czech Republic
    DE: Germany
    DK: Denmark
    EE: Estonia
    EL: Greece
    ES: Spain
    FI: Finland
    FR: France
    GB: United Kingdom
    HR: Croatia
    HU: Hungary
    IE: Ireland
    IT: Italy
    LT: Lithuania
    LU: Luxembourg
    LV: Latvia
    MT: Malta
    NL: Netherlands
    PL: Poland
    PT: Portugal
    RO: Romania
    SE: Sweden
    SI: Slovenia
    SK: Slovakia
  """

  @regexes %{
    "AT" => ~r/\AATU[0-9]{8}\Z/u,
    "BE" => ~r/\ABE0[0-9]{9}\Z/u,
    "BG" => ~r/\ABG[0-9]{9,10}\Z/u,
    "CY" => ~r/\ACY[0-9]{8}[A-Z]\Z/u,
    "CZ" => ~r/\ACZ[0-9]{8,10}\Z/u,
    "DE" => ~r/\ADE[0-9]{9}\Z/u,
    "DK" => ~r/\ADK[0-9]{8}\Z/u,
    "EE" => ~r/\AEE[0-9]{9}\Z/u,
    "EL" => ~r/\AEL[0-9]{9}\Z/u,
    "ES" => ~r/\AES([A-Z][0-9]{8}|[0-9]{8}[A-Z]|[A-Z][0-9]{7}[A-Z])\Z/u,
    "FI" => ~r/\AFI[0-9]{8}\Z/u,
    "FR" => ~r/\AFR[A-Z0-9]{2}[0-9]{9}\Z/u,
    "GB" => ~r/\AGB([0-9]{9}|[0-9]{12}|(HA|GD)[0-9]{3})\Z/u,
    "HR" => ~r/\AHR[0-9]{11}\Z/u,
    "HU" => ~r/\AHU[0-9]{8}\Z/u,
    "IE" => ~r/\AIE([0-9][A-Z][0-9]{5}|[0-9]{7}[A-Z]?)[A-Z]\Z/u,
    "IT" => ~r/\AIT[0-9]{11}\Z/u,
    "LT" => ~r/\ALT([0-9]{9}|[0-9]{12})\Z/u,
    "LU" => ~r/\ALU[0-9]{8}\Z/u,
    "LV" => ~r/\ALV[0-9]{11}\Z/u,
    "MT" => ~r/\AMT[0-9]{8}\Z/u,
    "NL" => ~r/\ANL[0-9]{9}B[0-9]{2}\Z/u,
    "PL" => ~r/\APL[0-9]{10}\Z/u,
    "PT" => ~r/\APT[0-9]{9}\Z/u,
    "RO" => ~r/\ARO[1-9][0-9]{1,9}\Z/u,
    "SE" => ~r/\ASE[0-9]{12}\Z/u,
    "SI" => ~r/\ASI[0-9]{8}\Z/u,
    "SK" => ~r/\ASK[0-9]{10}\Z/u
  }

  @countries Map.keys(@regexes)

  @spec valid_format?(binary) :: boolean
  @doc ~S"""
  Determines whether or not a VAT identification number has a valid format by
  checking to see if it matches any of the country-specific regexes.

  Returns `true` if the VAT number matches one of the regexes, and returns `false`
  otherwise.
  """
  def valid_format?(vat) when byte_size(vat) <= 2, do: false

  def valid_format?(<<country::binary-size(2), _::binary>>) when country not in @countries,
    do: false

  def valid_format?(vat = <<country::binary-size(2), _::binary>>) do
    @regexes
    |> Map.get(country)
    |> Regex.match?(vat)
  end
end
