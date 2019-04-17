defmodule ExVatcheck.CountriesTest do
  use ExUnit.Case

  alias ExVatcheck.{Countries, VAT}

  @valid_vats [
    "ATU99999999",
    "BE0999999999",
    "BG999999999",
    "BG9999999999",
    "CY99999999L",
    "CZ99999999",
    "CZ999999999",
    "CZ9999999999",
    "DE999999999",
    "DK99 99 99 99",
    "EE999999999",
    "EL999999999",
    "ESX9999999X",
    "FI99999999",
    "FRXX 999999999",
    "GB999 9999 99",
    "GB999 9999 99 999",
    "GBGD999",
    "GBHA999",
    "HR99999999999",
    "HU99999999",
    "IE9S99999L",
    "IE9999999WI",
    "IT99999999999",
    "LT999999999",
    "LT999999999999",
    "LU99999999",
    "LV99999999999",
    "MT99999999",
    "NL999999999B99",
    "PL9999999999",
    "PT999999999",
    "RO999999999",
    "SE999999999999",
    "SI99999999",
    "SK9999999999"
  ]

  @invalid_vats [
    "",
    "XX",
    "XX9999999999",
    "123456789"
  ]

  describe "valid_format?/2" do
    test "returns true if VAT format matches country regex" do
      assert Enum.all?(@valid_vats, &(&1 |> VAT.normalize() |> Countries.valid_format?()))
    end

    test "returns false for invalid formats" do
      refute Enum.any?(@invalid_vats, &(&1 |> VAT.normalize() |> Countries.valid_format?()))
    end
  end
end
