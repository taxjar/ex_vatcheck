defmodule ExVatcheckTest do
  use ExUnit.Case

  alias ExVatcheck
  alias ExVatcheck.VAT
  alias Fixtures.VIESResponses

  import Mimic

  @valid_vat_response %{
    country_code: "GB",
    vat_number: "333289454",
    request_date: "2016-01-16",
    valid: true,
    name: "BRITISH BROADCASTING CORPORATION",
    address: "BC0 B1 D1 BROADCAST CENTRE\nWHITE CITY PLACE\n201 WOOD LANE\nLONDON\n\nW12 7TP"
  }

  @invalid_vat_response %{
    country_code: "GB",
    vat_number: nil,
    request_date: "2016-01-16",
    valid: false,
    name: "---",
    address: "---"
  }

  describe "check/1" do
    setup :verify_on_exit!

    test "returns valid struct with response for valid vat" do
      expected = %VAT{
        valid: true,
        exists: true,
        vies_available: true,
        vies_response: @valid_vat_response
      }

      stub(HTTPoison, :post, fn _, _, _ ->
        {:ok, %HTTPoison.Response{body: VIESResponses.valid_vat_response()}}
      end)

      assert ExVatcheck.check("GB333289454") == expected
    end

    test "returns valid struct with response for invalid vat" do
      expected = %VAT{
        valid: false,
        exists: false,
        vies_available: true,
        vies_response: @invalid_vat_response
      }

      stub(HTTPoison, :post, fn _, _, _ ->
        {:ok, %HTTPoison.Response{body: VIESResponses.invalid_vat_response()}}
      end)

      assert ExVatcheck.check("GB123123123") == expected
    end

    test "falls back to regex if service unavailable" do
      expected = %VAT{
        valid: true,
        exists: false,
        vies_available: false,
        vies_response: %{error: "Service timed out"}
      }

      stub(HTTPoison, :post, fn _, _, _ ->
        {:error, %HTTPoison.Error{reason: :timeout}}
      end)

      assert ExVatcheck.check("GB333289454") == expected
    end

    test "returns empty struct if country regex not matched" do
      assert ExVatcheck.check("XX123456789") == %VAT{}
    end

    test "gracefully handles non-alphanumeric characters" do
      expected = %VAT{
        valid: false,
        exists: false,
        vies_available: true,
        vies_response: @invalid_vat_response
      }

      stub(HTTPoison, :post, fn _, _, _ ->
        {:ok, %HTTPoison.Response{body: VIESResponses.invalid_vat_response()}}
      end)

      assert ExVatcheck.check("'GB123123123[]'") == expected
    end

    @tag external: true
    test "Smoke check" do
      assert %ExVatcheck.VAT{
               exists: true,
               valid: true,
               vies_available: true,
               vies_response: %{
                 address: "Tobelbader Straße 30\nAT-8141 Premstätten",
                 country_code: "AT",
                 name: "ams AG",
                 request_date: _date,
                 valid: true,
                 vat_number: "U28560205"
               }
             } = ExVatcheck.check("ATU28560205")
    end
  end
end
