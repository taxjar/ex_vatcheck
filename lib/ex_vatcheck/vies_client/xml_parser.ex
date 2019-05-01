defmodule ExVatcheck.VIESClient.XMLParser do
  @moduledoc """
  A module for parsing XML responses from VIES client requests into Elixir maps.
  """

  @type response :: %{
          country_code: binary,
          vat_number: binary,
          request_date: binary,
          valid: boolean,
          name: binary,
          address: binary
        }

  @check_vat_service_url SweetXml.sigil_x(
                           "//wsdl:definitions/wsdl:service[name=checkVatService]/wsdl:port[name=checkVatPort]/wsdlsoap:address/@location"
                         )

  @check_vat_fault SweetXml.sigil_x("//soap:Envelope/soap:Body/soap:Fault/faultstring/text()")
  @check_vat_response SweetXml.sigil_x("//soap:Envelope/soap:Body/checkVatResponse")

  @check_vat_response_fields [
    country_code: SweetXml.sigil_x("./countryCode/text()"),
    vat_number: SweetXml.sigil_x("./vatNumber/text()"),
    request_date: SweetXml.sigil_x("./requestDate/text()"),
    valid: SweetXml.sigil_x("./valid/text()"),
    name: SweetXml.sigil_x("./name/text()"),
    address: SweetXml.sigil_x("./address/text()")
  ]

  @doc ~S"""
  The parse_service/1 function parses the URL of the checkVatService from the
  VIES WSDL response. The WSDL has the following structure:

  <wsdl:definitions ...>
    ...
    <wsdl:service name="checkVatService">
      <wsdl:port name="checkVatPort" binding="impl:checkVatBinding">
        <wsdlsoap:address location="http://ec.europa.eu/taxation_customs/vies/services/checkVatService"/>
      </wsdl:port>
    </wsdl:service>
  </wsdl:definitions>
  """
  @spec parse_service(binary) :: {:ok, binary} | {:error, binary}
  def parse_service(wsdl_response) do
    case SweetXml.xpath(wsdl_response, @check_vat_service_url) do
      nil -> {:error, :invalid_wsdl}
      url -> {:ok, to_string(url)}
    end
  end

  @doc ~S"""
  The parse_response/1 function parses the XML response returned by requests to
  the checkVatService. When the service is up, the response has the following
  structure:

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

  Sometimes, the VIES service is unavailable (see http://ec.europa.eu/taxation_customs/vies/help.html).
  In the case that it is not, the response has the following structure:

  <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
      <soap:Fault>
        ...
      </soap:Fault>
    </soap:Body>
  </soap:Envelope>
  """
  @spec parse_response(binary) :: {:ok, map} | {:error, binary}
  def parse_response(response_body) do
    if fault = SweetXml.xpath(response_body, @check_vat_fault) do
      {:error, fault |> to_string() |> format_fault()}
    else
      body = SweetXml.xpath(response_body, @check_vat_response, @check_vat_response_fields)
      {:ok, format_fields(body)}
    end
  end

  @spec format_fields(response) :: response
  defp format_fields(body) do
    %{
      country_code: to_string(body.country_code),
      vat_number: to_string(body.vat_number),
      request_date: to_string(body.request_date),
      valid: body.valid == 'true',
      name: body.name |> to_string(),
      address: body.address |> to_string()
    }
  end

  @spec format_fault(binary) :: binary
  defp format_fault(fault) do
    if String.contains?(fault, "MS_UNAVAILABLE") do
      "Service unavailable"
    else
      "Unknown error: #{fault}"
    end
  end
end
