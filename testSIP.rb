require 'LIBIS_Tools'

class RosettaDepositor
  include LIBIS::Tools::Webservices::SoapClient

  def initialize(base_url)
    configure "#{base_url}/dpsws/deposit/DepositWebServices?wsdl"
  end

  def login(name, password, institute)

  end
end
