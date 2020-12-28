defmodule ExVatcheck.HMRCClient do
  @moduledoc """
  The ExVatcheck.HMRCClient module provides a client for the HM Revenue
  & Customs VAT identification number service.

  https://developer.service.hmrc.gov.uk/api-documentation/docs/api/service/vat-registered-companies-api/1.0
  """

  defstruct [:url, :token]

  @type t :: %__MODULE__{
          url: binary(),
          token: binary()
        }

  @spec new() :: {:ok, t()} | {:error, binary} | {:error, HTTPoison.Error.t()}
  def new() do
    base_url = Application.get_env(:ex_vatcheck, :hmrc_url)
    url = base_url <> "/oauth/token"

    body =
      {:form,
       [
         {"grant_type", "client_credentials"},
         {"client_secret", Application.get_env(:ex_vatcheck, :hmrc_secret)},
         {"client_id", Application.get_env(:ex_vatcheck, :hmrc_client_id)}
       ]}

    with {:ok, response} <- HTTPoison.post(url, body, [{"Content-Type", "application/x-www-form-urlencoded"}]),
         {:ok, decoded_response} <- Jason.decode(response.body) do
      {:ok, %__MODULE__{url: base_url, token: decoded_response["access_token"]}}
    else
      {:error, %HTTPoison.Error{reason: :timeout}} -> {:error, "Service timed out"}
      {:error, %Jason.DecodeError{}} -> {:error, "Bad response"}
      error -> error
    end
  end

  @spec check_vat(t(), binary) ::
          {:ok, map} | {:error, binary} | {:error, HTTPoison.Error.t()}
  def check_vat(client, vat_number) do
    url = client.url <> "/organisations/vat/check-vat-number/lookup/" <> vat_number

    with {:ok, response} <- HTTPoison.get(url, build_headers(client)),
         {:ok, decoded_response} <- Jason.decode(response.body) do
      {:ok, decoded_response}
    else
      {:error, %HTTPoison.Error{reason: :timeout}} -> {:error, "Service timed out"}
      {:error, %Jason.DecodeError{}} -> {:error, "Bad response"}
      error -> error
    end
  end

  defp build_headers(client) do
    [
      {"Authorization", "Bearer #{client.token}"},
      {"Accept", "application/vnd.hmrc.1.0+json"}
    ]
  end
end
