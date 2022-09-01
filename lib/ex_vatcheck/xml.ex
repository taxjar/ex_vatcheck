defmodule ExVatcheck.Xml do
  @moduledoc false
  require SweetXml

  def parse(doc, spec, subspec \\ [])

  def parse(doc, spec, subspec) when is_binary(doc) do
    doc
    |> SweetXml.parse(dtd: :none)
    |> parse(spec, subspec)
  end

  def parse(doc, %SweetXpath{} = spec, []) when is_tuple(doc) do
    SweetXml.xpath(doc, spec)
  end

  def parse(doc, %SweetXpath{} = spec, subspec) when is_tuple(doc) do
    if SweetXml.xpath(doc, spec) do
      SweetXml.xpath(doc, spec, subspec)
    else
      nil
    end
  end
end
