defmodule ExVatcheck.VIESClientTest do
  use ExUnit.Case

  alias ExVatcheck.VIESClient
  alias Fixtures.VIESResponses

  import Mimic

  describe "new/0" do
    setup :verify_on_exit!

    test "creates a new VIES client" do
      stub(HTTPoison, :get, fn _ ->
        {:ok, %HTTPoison.Response{body: VIESResponses.valid_wsdl()}}
      end)

      assert VIESClient.new() == {:ok, %VIESClient{url: VIESResponses.service_url()}}
    end

    test "errors on HTTPoison error" do
      error = {:error, %HTTPoison.Error{id: nil, reason: :unexpected_error}}

      stub(HTTPoison, :get, fn _ -> error end)

      assert VIESClient.new() == error
    end

    test "error when invalid WSDL XML returned" do
      stub(HTTPoison, :get, fn _ ->
        {:ok, %HTTPoison.Response{body: VIESResponses.invalid_wsdl()}}
      end)

      assert VIESClient.new() == {:error, VIESResponses.invalid_wsdl()}
    end
  end

  describe "check_vat/3" do
    test "correctly verifies a valid VAT identification number" do
      client = %VIESClient{url: VIESResponses.service_url()}

      expected = %{
        country_code: "GB",
        vat_number: "333289454",
        request_date: "2016-01-16+01:00",
        valid: true,
        name: "BRITISH BROADCASTING CORPORATION",
        address: "BC0 B1 D1 BROADCAST CENTRE\nWHITE CITY PLACE\n201 WOOD LANE\nLONDON\n\nW12 7TP"
      }

      stub(HTTPoison, :post, fn _, _ ->
        {:ok, %HTTPoison.Response{body: VIESResponses.valid_vat_response()}}
      end)

      assert VIESClient.check_vat(client, "GB", "333289454") == {:ok, expected}
    end

    test "correctly marks an invalid VAT identification number" do
      client = %VIESClient{url: VIESResponses.service_url()}

      expected = %{
        country_code: "GB",
        vat_number: "123123123",
        request_date: "2016-01-16+01:00",
        valid: false,
        name: "---",
        address: "---"
      }

      stub(HTTPoison, :post, fn _, _ ->
        {:ok, %HTTPoison.Response{body: VIESResponses.invalid_vat_response()}}
      end)

      assert VIESClient.check_vat(client, "GB", "123123123") == {:ok, expected}
    end

    test "gracefully handles error due to unavailable VIES service" do
      client = %VIESClient{url: VIESResponses.service_url()}

      stub(HTTPoison, :post, fn _, _ ->
        {:ok, %HTTPoison.Response{body: VIESResponses.service_unavailable_response()}}
      end)

      assert VIESClient.check_vat(client, "GB", "123123123") == {:error, "Service unavailable"}
    end
  end
end
