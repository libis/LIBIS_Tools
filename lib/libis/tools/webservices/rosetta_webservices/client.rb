# coding: utf-8

require 'libis/tools/webservices/soap_client'
require 'libis/tools/extend/hash'

module LIBIS
  module Tools
    module Webservices
      module RosettaServices

        class Client
          include LIBIS::Tools::Webservices::SoapClient

          def initialize(section, service, base_url = 'http://depot.lias.be')
            configure "#{base_url}/dpsws/#{section}/#{service}?wsdl"
          end

          def pds_handle=(handle)
            @pds_handle = handle
          end

          def get_heart_bit
            request :get_heart_bit
          end

          protected

          def result_parser(response)
            response.body.values.first.values.first rescue nil
          end

        end

      end
    end
  end
end
