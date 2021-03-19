defmodule ExVatcheck.VIESClient do
  @moduledoc """
  The ExVatcheck.Vies module provides a client for the VIES VAT identification
  number service.
  """

  alias ExVatcheck.VIESClient.XMLParser

  @wsdl_url "https://ec.europa.eu/taxation_customs/vies/checkVatService.wsdl"

  defstruct [:url]

  @type t :: %__MODULE__{
          url: binary
        }

  @spec check_vat(t(), binary, binary) ::
          {:ok, map} | {:error, binary} | {:error, HTTPoison.Error.t()}
  @doc ~S"""
  Queries the VIES service to determine whether or not the provided VAT
  identification number is valid.

  Returns `{:ok, response}` in the case of a successful call to the service, and
  `{:error, error}` in the case that the service could not be reached or the XML
  response could not be parsed.
  """
  def check_vat(client, country_code, vat_number) do
    req_body = vat_request(country_code, vat_number)

    case HTTPoison.post(client.url, req_body) do
      {:ok, response} -> XMLParser.parse_response(response.body)
      {:error, %HTTPoison.Error{reason: :timeout}} -> {:error, "Service timed out"}
    end
  end

  @spec new() :: {:ok, t()} | {:error, any}
  @doc ~S"""
  Returns a new VIES client struct which can be used to make requests in
  `check_vat/3`. If the VIES service times out, or if invalid WSDL is returned
  and the checkVat service URL cannot be parsed, an error is returned.
  """
  def new do
    with {:ok, response} <- HTTPoison.get(@wsdl_url),
         {:ok, url} <- XMLParser.parse_service(response.body) do
      {:ok, %__MODULE__{url: corrected_client_url(url)}}
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

  # NOTE: VIES currently sends back an invalid URL in the client which uses http
  #       instead of https, which they have recently updated to.
  @spec corrected_client_url(binary) :: binary
  defp corrected_client_url("https" <> _ = url), do: url
  defp corrected_client_url(url), do: String.replace(url, "http://", "https://")
end
