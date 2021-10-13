defmodule ExVatcheck.Xml do
  @moduledoc false
  require SweetXml

  def parse(doc, %SweetXpath{} = spec, subspec \\ []) when is_binary(doc) do
    doc
    |> SweetXml.parse(dtd: :none)
    |> SweetXml.xpath(spec, subspec)
  end
end
