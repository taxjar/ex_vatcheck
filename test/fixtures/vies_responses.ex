defmodule Fixtures.VIESResponses do
  @moduledoc """
  The Fixtures.VIESResponses provides mock responses from the VIES checkVat service.
  """

  def service_url do
    "https://ec.europa.eu/taxation_customs/vies/services/checkVatService"
  end

  def valid_wsdl do
    """
    <wsdl:definitions>
      <wsdl:service name="checkVatService">
        <wsdl:port name="checkVatPort" binding="impl:checkVatBinding">
          <wsdlsoap:address location="#{service_url()}"/>
        </wsdl:port>
      </wsdl:service>
    </wsdl:definitions>
    """
  end

  def invalid_wsdl do
    "<wsdl:definitions/>"
  end

  def valid_vat_response do
    """
    <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
      <env:Header/>
      <env:Body>
        <ns2:checkVatResponse xmlns:ns2="urn:ec.europa.eu:taxud:vies:services:checkVat:types">
          <ns2:countryCode>GB</ns2:countryCode>
          <ns2:vatNumber>333289454</ns2:vatNumber>
          <ns2:requestDate>2016-01-16+01:00</ns2:requestDate>
          <ns2:valid>true</ns2:valid>
          <ns2:name>BRITISH BROADCASTING CORPORATION</ns2:name>
          <ns2:address>BC0 B1 D1 BROADCAST CENTRE\nWHITE CITY PLACE\n201 WOOD LANE\nLONDON\n\nW12 7TP</ns2:address>
        </ns2:checkVatResponse>
      </env:Body>
    </env:Envelope>
    """
  end

  def invalid_vat_response do
    """
    <env:Envelope xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\">
      <env:Header/>
      <env:Body>
        <ns2:checkVatResponse xmlns:ns2=\"urn:ec.europa.eu:taxud:vies:services:checkVat:types\">
          <ns2:countryCode>GB</ns2:countryCode>
          <ns2:vatNumber></ns2:vatNumber>
          <ns2:requestDate>2016-01-16+00:00</ns2:requestDate>
          <ns2:valid>false</ns2:valid>
          <ns2:name>---</ns2:name>
          <ns2:address>---</ns2:address>
        </ns2:checkVatResponse>
      </env:Body>
    </env:Envelope>
    """
  end

  def invalid_input_fault_response do
    """
    <env:Envelope xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\">
      <env:Header/>
      <env:Body>
        <env:Fault>
          <faultcode>env:Server</faultcode>
          <faultstring>INVALID_INPUT</faultstring>
        </env:Fault>
      </env:Body>
    </env:Envelope>
    """
  end

  def service_unavailable_response do
    """
    <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
      <env:Header/>
      <env:Body>
        <env:Fault>
          <faultstring>MS_UNAVAILABLE</faultstring>
        </env:Fault>
      </env:Body>
    </env:Envelope>
    """
  end
end
