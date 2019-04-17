defmodule ExVatcheck.VIESClient.XMLParserTest do
  use ExUnit.Case

  alias ExVatcheck.VIESClient.XMLParser

  describe "parse_service/1" do
    test "parses the checkVatService url from the VIES WSDL response" do
      url = "http://ec.europa.eu/taxation_customs/vies/services/checkVatService"

      response = """
      <wsdl:definitions>
        <wsdl:service name="checkVatService">
          <wsdl:port name="checkVatPort" binding="impl:checkVatBinding">
            <wsdlsoap:address location="#{url}"/>
          </wsdl:port>
        </wsdl:service>
      </wsdl:definitions>
      """

      assert XMLParser.parse_service(response) == {:ok, url}
    end

    test "returns an error when the service URL cannot be found" do
      response = """
      <wsdl:definitions>
        <wsdl:service name="checkVatService">
          <wsdl:port name="checkVatPort" binding="impl:checkVatBinding">
            <wsdlsoap:address/>
          </wsdl:port>
        </wsdl:service>
      </wsdl:definitions>
      """

      assert XMLParser.parse_service(response) == {:error, response}
    end
  end

  describe "parse_response/1" do
    test "parses the XML response from the checkVatService into a map" do
      response = """
      <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <checkVatResponse xmlns="urn:ec.europa.eu:taxud:vies:services:checkVat:types">
            <countryCode>BE</countryCode>
            <vatNumber>0829071668</vatNumber>
            <requestDate>2016-01-16+01:00</requestDate>
            <valid>true</valid>
            <name>SPRL BIGUP</name>
            <address>RUE LONGUE 93 1320 BEAUVECHAIN</address>
          </checkVatResponse>
        </soap:Body>
      </soap:Envelope>
      """

      expected = %{
        country_code: "BE",
        vat_number: "0829071668",
        request_date: "2016-01-16+01:00",
        valid: true,
        name: "SPRL BIGUP",
        address: "RUE LONGUE 93 1320 BEAUVECHAIN"
      }

      assert XMLParser.parse_response(response) == {:ok, expected}
    end

    test "parses the XML response for invalid VAT identifcation number" do
      response = """
      <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <checkVatResponse xmlns="urn:ec.europa.eu:taxud:vies:services:checkVat:types">
            <countryCode>BE</countryCode>
            <vatNumber>123123123</vatNumber>
            <requestDate>2016-01-16+01:00</requestDate>
            <valid>false</valid>
            <name>---</name>
            <address>---</address>
          </checkVatResponse>
        </soap:Body>
      </soap:Envelope>
      """

      expected = %{
        country_code: "BE",
        vat_number: "123123123",
        request_date: "2016-01-16+01:00",
        valid: false,
        name: "---",
        address: "---"
      }

      assert XMLParser.parse_response(response) == {:ok, expected}
    end

    test "gracefully handles when VIES service unavailable" do
      fault = """
        <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <soap:Fault>
              <faultstring>MS_UNAVAILABLE</faultstring>
            </soap:Fault>
          </soap:Body>
        </soap:Envelope>
      """

      assert XMLParser.parse_response(fault) == {:error, "Service unavailable"}
    end

    test "gracefully handles unexpected errors from the VIES service" do
      fault = """
        <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <soap:Fault>
              <faultstring>XML_ERROR</faultstring>
            </soap:Fault>
          </soap:Body>
        </soap:Envelope>
      """

      assert XMLParser.parse_response(fault) == {:error, "Unexpected error: XML_ERROR"}
    end
  end
end
