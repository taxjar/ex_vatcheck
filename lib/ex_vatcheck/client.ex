defmodule ExVatcheck.Client do
  @moduledoc """
  Interface to choose which client to use

  VIES or HMRC
  """

  alias ExVatcheck.{HMRCClient, VIESClient}

  @spec new(binary()) :: HMRCClient.t()
  def new("GB") do
    HMRCClient.new()
  end

  @spec new(binary()) :: VIESClient.t()
  def new(_) do
    VIESClient.new()
  end

  @spec check_vat(VIESClient.t() | HRMCClient.t(), binary, binary) ::
          {:ok, map} | {:error, binary} | {:error, HTTPoison.Error.t()}
  def check_vat(client, "GB", vat_number) do
    HMRCClient.check_vat(client, vat_number)
  end

  def check_vat(client, country_code, vat_number) do
    VIESClient.check_vat(client, country_code, vat_number)
  end
end
