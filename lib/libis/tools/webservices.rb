module LIBIS
  module Tools
    module Webservices

      autoload :SoapClient, 'libis/tools/webservices/soap_client'
      autoload :RestClient, 'libis/tools/webservices/rest_client'

      autoload :DigitoolConnector, 'lib/libis/tools/webservices/digitool_connector'
      autoload :DigitalEntityManager, 'libis/tools/webservices/digital_entity_manager'
      autoload :MetaDataManager, 'libis/tools/webservices/meta_data_manager'

      autoload :SharepointConnector, 'libis/tools/webservices/sharepoint_connector'

      autoload :Rosetta, 'libis/tools/webservices/rosetta'

    end
  end
end