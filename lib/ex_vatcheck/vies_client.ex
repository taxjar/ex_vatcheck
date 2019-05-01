defmodule ExVatcheck.VIESClient do
  @moduledoc """
  The ExVatcheck.Vies module provides a client for the VIES VAT identification
  number service.
  """

  alias ExVatcheck.VIESClient.XMLParser

  @wsdl_url "http://ec.europa.eu/taxation_customs/vies/checkVatService.wsdl"

  defstruct [:url]

  @type t :: %__MODULE__{
          url: binary
        }

  @spec check_vat(t(), binary, binary) ::
          {:ok, map} | {:error, binary} | {:error, HTTPoison.Error.t()}
  def check_vat(client, country_code, vat_number) do
    req_body = vat_request(country_code, vat_number)

    case HTTPoison.post(client.url, req_body) do
      {:ok, response} -> XMLParser.parse_response(response.body)
      {:error, %HTTPoison.Error{reason: :timeout}} -> {:error, "Service timed out"}
    end
  end

  @spec new() :: {:ok, t()} | {:error, any}
  def new() do
    with {:ok, response} <- HTTPoison.get(@wsdl_url),
         {:ok, url} <- XMLParser.parse_service(response.body) do
      {:ok, %__MODULE__{url: url}}
    else
      {:error, %HTTPoison.Error{reason: :timeout}} -> {:error, "Service timed out"}
      {:error, :invalid_wsdl} -> {:error, "Unknown error: invalid_wsdl"}
      {:error, error} -> {:error, "Unknown error: #{error.reason}"}
    end
  end

  @spec vat_request(binary, binary) :: binary
  defp vat_request(country_code, vat_number) do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="urn:ec.europa.eu:taxud:vies:services:checkVat:types">
      <soap:Body>
        <ns1:checkVat>
          <ns1:countryCode>#{country_code}</ns1:countryCode>
          <ns1:vatNumber>#{vat_number}</ns1:vatNumber>
        </ns1:checkVat>
      </soap:Body>
    </soap:Envelope>
    """
  end
end
