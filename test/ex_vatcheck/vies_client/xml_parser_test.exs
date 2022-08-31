defmodule ExVatcheck.VIESClient.XMLParserTest do
  use ExUnit.Case

  alias ExVatcheck.VIESClient.XMLParser

  describe "parse_service/1" do
    test "parses the checkVatService url from the VIES WSDL response" do
      url = "https://ec.europa.eu/taxation_customs/vies/services/checkVatService"

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

      assert XMLParser.parse_service(response) == {:error, :invalid_wsdl}
    end
  end

  describe "parse_response/1" do
    test "parses the XML response from the checkVatService into a map" do
      response = """
      <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
        <env:Body>
          <ns2:checkVatResponse xmlns:ns2="urn:ec.europa.eu:taxud:vies:services:checkVat:types">
            <ns2:countryCode>BE</ns2:countryCode>
            <ns2:vatNumber>0829071668</ns2:vatNumber>
            <ns2:requestDate>2016-01-16+01:00</ns2:requestDate>
            <ns2:valid>true</ns2:valid>
            <ns2:name>SPRL BIGUP</ns2:name>
            <ns2:address>RUE LONGUE 93 1320 BEAUVECHAIN</ns2:address>
          </ns2:checkVatResponse>
        </env:Body>
      </env:Envelope>
      """

      expected = %{
        country_code: "BE",
        vat_number: "0829071668",
        request_date: "2016-01-16",
        valid: true,
        name: "SPRL BIGUP",
        address: "RUE LONGUE 93 1320 BEAUVECHAIN"
      }

      assert XMLParser.parse_response(response) == {:ok, expected}
    end

    test "parses the XML response for invalid VAT identifcation number" do
      response = """
      <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
        <env:Body>
          <ns2:checkVatResponse xmlns:ns2="urn:ec.europa.eu:taxud:vies:services:checkVat:types">
            <ns2:countryCode>BE</ns2:countryCode>
            <ns2:vatNumber>123123123</ns2:vatNumber>
            <ns2:requestDate>2016-01-16+01:00</ns2:requestDate>
            <ns2:valid>false</ns2:valid>
            <ns2:name>---</ns2:name>
            <ns2:address>---</ns2:address>
          </ns2:checkVatResponse>
        </env:Body>
      </env:Envelope>
      """

      expected = %{
        country_code: "BE",
        vat_number: "123123123",
        request_date: "2016-01-16",
        valid: false,
        name: "---",
        address: "---"
      }

      assert XMLParser.parse_response(response) == {:ok, expected}
    end

    test "correctly keeps nil values when present in checkVat response" do
      response = """
      <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
        <env:Body>
          <ns2:checkVatResponse xmlns:ns2="urn:ec.europa.eu:taxud:vies:services:checkVat:types">
            <ns2:countryCode>BG</ns2:countryCode>
            <ns2:vatNumber>451158821</ns2:vatNumber>
            <ns2:requestDate>2016-01-16+01:00</ns2:requestDate>
            <ns2:valid>false</ns2:valid>
            <ns2:name></ns2:name>
            <ns2:address></ns2:address>
          </ns2:checkVatResponse>
        </env:Body>
      </env:Envelope>
      """

      expected = %{
        country_code: "BG",
        vat_number: "451158821",
        request_date: "2016-01-16",
        valid: false,
        name: nil,
        address: nil
      }

      assert XMLParser.parse_response(response) == {:ok, expected}
    end

    test "gracefully handles unexpected date formats" do
      response = """
      <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
        <env:Body>
          <ns2:checkVatResponse xmlns:ns2="urn:ec.europa.eu:taxud:vies:services:checkVat:types">
            <ns2:countryCode>BG</ns2:countryCode>
            <ns2:vatNumber>451158821</ns2:vatNumber>
            <ns2:requestDate>2016-01</ns2:requestDate>
            <ns2:valid>false</ns2:valid>
            <ns2:name></ns2:name>
            <ns2:address></ns2:address>
          </ns2:checkVatResponse>
        </env:Body>
      </env:Envelope>
      """

      expected = %{
        country_code: "BG",
        vat_number: "451158821",
        request_date: "2016-01",
        valid: false,
        name: nil,
        address: nil
      }

      assert XMLParser.parse_response(response) == {:ok, expected}
    end

    test "gracefully handles when VIES service unavailable" do
      fault = """
        <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
          <env:Body>
            <env:Fault>
              <faultstring>MS_UNAVAILABLE</faultstring>
            </env:Fault>
          </env:Body>
        </env:Envelope>
      """

      assert XMLParser.parse_response(fault) == {:error, "Service unavailable"}
    end

    test "gracefully handles unexpected errors from the VIES service" do
      fault = """
        <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
          <env:Body>
            <env:Fault>
              <faultstring>XML_ERROR</faultstring>
            </env:Fault>
          </env:Body>
        </env:Envelope>
      """

      assert XMLParser.parse_response(fault) == {:error, "Unknown error: XML_ERROR"}
    end
  end
end
