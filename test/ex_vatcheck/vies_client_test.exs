defmodule ExVatcheck.VIESClientTest do
  use ExUnit.Case

  alias ExVatcheck.VIESClient

  import Mimic

  @service_url "http://ec.europa.eu/taxation_customs/vies/services/checkVatService"

  @valid_wsdl """
  <wsdl:definitions>
    <wsdl:service name="checkVatService">
      <wsdl:port name="checkVatPort" binding="impl:checkVatBinding">
        <wsdlsoap:address location="#{@service_url}"/>
      </wsdl:port>
    </wsdl:service>
  </wsdl:definitions>
  """

  @invalid_wsdl "<wsdl:definitions/>"

  describe "new/0" do
    setup :verify_on_exit!

    test "creates a new VIES client" do
      stub(HTTPoison, :get, fn _ ->
        {:ok, %HTTPoison.Response{body: @valid_wsdl}}
      end)

      assert VIESClient.new() == {:ok, %VIESClient{url: @service_url}}
    end

    test "errors on HTTPoison error" do
      error = {:error, %HTTPoison.Error{id: nil, reason: :unexpected_error}}

      stub(HTTPoison, :get, fn _ -> error end)

      assert VIESClient.new() == error
    end

    test "error when invalid WSDL XML returned" do
      stub(HTTPoison, :get, fn _ ->
        {:ok, %HTTPoison.Response{body: @invalid_wsdl}}
      end)

      assert VIESClient.new() == {:error, @invalid_wsdl}
    end
  end

  @valid_vat_response """
  <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
      <checkVatResponse xmlns="urn:ec.europa.eu:taxud:vies:services:checkVat:types">
        <countryCode>GB</countryCode>
        <vatNumber>333289454</vatNumber>
        <requestDate>2016-01-16+01:00</requestDate>
        <valid>true</valid>
        <name>BRITISH BROADCASTING CORPORATION</name>
        <address>BC0 B1 D1 BROADCAST CENTRE\nWHITE CITY PLACE\n201 WOOD LANE\nLONDON\n\nW12 7TP</address>
      </checkVatResponse>
    </soap:Body>
  </soap:Envelope>
  """

  @invalid_vat_response """
  <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
      <checkVatResponse xmlns="urn:ec.europa.eu:taxud:vies:services:checkVat:types">
        <countryCode>GB</countryCode>
        <vatNumber>123123123</vatNumber>
        <requestDate>2016-01-16+01:00</requestDate>
        <valid>false</valid>
        <name>---</name>
        <address>---</address>
      </checkVatResponse>
    </soap:Body>
  </soap:Envelope>
  """

  @service_unavailable_response """
    <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <soap:Fault>
          <faultstring>MS_UNAVAILABLE</faultstring>
        </soap:Fault>
      </soap:Body>
    </soap:Envelope>
  """

  describe "check_vat/3" do
    test "correctly verifies a valid VAT identification number" do
      client = %VIESClient{url: @service_url}

      expected = %{
        country_code: "GB",
        vat_number: "333289454",
        request_date: "2016-01-16+01:00",
        valid: true,
        name: "BRITISH BROADCASTING CORPORATION",
        address: "BC0 B1 D1 BROADCAST CENTRE\nWHITE CITY PLACE\n201 WOOD LANE\nLONDON\n\nW12 7TP"
      }

      stub(HTTPoison, :post, fn _, _ ->
        {:ok, %HTTPoison.Response{body: @valid_vat_response}}
      end)

      assert VIESClient.check_vat(client, "GB", "333289454") == {:ok, expected}
    end

    test "correctly marks an invalid VAT identification number" do
      client = %VIESClient{url: @service_url}

      expected = %{
        country_code: "GB",
        vat_number: "123123123",
        request_date: "2016-01-16+01:00",
        valid: false,
        name: nil,
        address: nil
      }

      stub(HTTPoison, :post, fn _, _ ->
        {:ok, %HTTPoison.Response{body: @invalid_vat_response}}
      end)

      assert VIESClient.check_vat(client, "GB", "123123123") == {:ok, expected}
    end

    test "gracefully handles error due to unavailable VIES service" do
      client = %VIESClient{url: @service_url}

      stub(HTTPoison, :post, fn _, _ ->
        {:ok, %HTTPoison.Response{body: @service_unavailable_response}}
      end)

      assert VIESClient.check_vat(client, "GB", "123123123") == {:error, "Service unavailable"}
    end
  end
end
