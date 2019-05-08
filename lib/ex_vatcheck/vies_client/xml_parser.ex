defmodule ExVatcheck.VIESClient.XMLParser do
  @moduledoc """
  A module for parsing XML responses from VIES client requests into Elixir maps.
  """

  @type response :: %{
          country_code: binary,
          vat_number: binary,
          request_date: binary,
          valid: boolean,
          name: binary | nil,
          address: binary | nil
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
  The `parse_service/1` function parses the URL of the checkVatService from the
  VIES WSDL response.

  The WSDL has the following structure:
  ```
  <wsdl:definitions ...>
    ...
    <wsdl:service name="checkVatService">
      <wsdl:port name="checkVatPort" binding="impl:checkVatBinding">
        <wsdlsoap:address location="http://ec.europa.eu/taxation_customs/vies/services/checkVatService"/>
      </wsdl:port>
    </wsdl:service>
  </wsdl:definitions>
  ```
  """
  @spec parse_service(binary) :: {:ok, binary} | {:error, binary}
  def parse_service(wsdl_response) do
    case SweetXml.xpath(wsdl_response, @check_vat_service_url) do
      nil -> {:error, :invalid_wsdl}
      url -> {:ok, to_string(url)}
    end
  end

  @doc ~S"""
  The `parse_response/1` function parses the XML response returned by requests to
  the checkVatService.

  When the service is available, the response has the following structure:
  ```
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
  ```

  Sometimes, the VIES service is unavailable (see http://ec.europa.eu/taxation_customs/vies/help.html).
  In the case that it is not, the response has the following structure:

  ```
  <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
      <soap:Fault>
        ...
      </soap:Fault>
    </soap:Body>
  </soap:Envelope>
  ```
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

  @spec format_fields(map) :: response
  defp format_fields(body) do
    %{
      country_code: format_field(body.country_code),
      vat_number: format_field(body.vat_number),
      request_date: body.request_date |> format_field() |> format_date(),
      valid: body.valid == 'true',
      name: format_field(body.name),
      address: format_field(body.address)
    }
  end

  @spec format_field(charlist | nil) :: binary | nil
  defp format_field(nil), do: nil
  defp format_field(charlist), do: to_string(charlist)

  @spec format_date(binary) :: binary
  defp format_date(<<date::binary-size(10), "+", _time::binary-size(5)>>), do: date
  defp format_date(date), do: date

  @spec format_fault(binary) :: binary
  defp format_fault(fault) do
    if String.contains?(fault, "MS_UNAVAILABLE") do
      "Service unavailable"
    else
      "Unknown error: #{fault}"
    end
  end
end
