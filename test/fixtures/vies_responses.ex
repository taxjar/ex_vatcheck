defmodule Fixtures.VIESResponses do
  @moduledoc """
  The Fixtures.VIESResponses provides mock responses from the VIES checkVat service.
  """

  def service_url do
    "http://ec.europa.eu/taxation_customs/vies/services/checkVatService"
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
    <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <checkVatResponse xmlns="urn:ec.europa.eu:taxud:vies:services:checkVat:types">
          <countryCode>GB</countryCode>
          <vatNumber>333289454</vatNumber>
          <requestDate>2016-01-16+01:00</requestDate>
          <valid>true</valid>
          <name>BRITISH BROADCASTING CORPORATION</name>
          <address>BC0 B1 D1 BROADCAST CENTRE\nWHITE CITY PLACE\n201 WOOD LANE\nLONDON\n\nW12 7TP</address>
        </checkVatResponse>
      </soap:Body>
    </soap:Envelope>
    """
  end

  def invalid_vat_response do
    """
    <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <checkVatResponse xmlns="urn:ec.europa.eu:taxud:vies:services:checkVat:types">
          <countryCode>GB</countryCode>
          <vatNumber>123123123</vatNumber>
          <requestDate>2016-01-16+01:00</requestDate>
          <valid>false</valid>
          <name>---</name>
          <address>---</address>
        </checkVatResponse>
      </soap:Body>
    </soap:Envelope>
    """
  end

  def service_unavailable_response do
    """
    <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <soap:Fault>
          <faultstring>MS_UNAVAILABLE</faultstring>
        </soap:Fault>
      </soap:Body>
    </soap:Envelope>
    """
  end
end
