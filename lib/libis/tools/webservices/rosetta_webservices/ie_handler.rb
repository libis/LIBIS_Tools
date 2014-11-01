# encoding: utf-8

require 'libis/tools/webservices/rosetta_webservices/client'
require 'libis/tools/xml_document'

module LIBIS
  module Tools
    module Webservices
      module RosettaServices

        class IeHandler < LIBIS::Tools::Webservices::RosettaServices::Client

          def initialize(base_url = 'http://depot.lias.be')
            super 'repository', 'IEWebServices', base_url
          end

          def get_mets(ie, flags = 0)
            reply = request(:get_ie, pds_handle: @pds_handle, ie_pid: ie, flags: flags)
            parse_xml_response reply rescue reply
          end

          def get_metadata(ie)
            reply = request(:get_md, pds_handle: @pds_handle, 'PID' => ie)
            parse_xml_response reply rescue reply
          end

          def parse_xml_response(response)
            LIBIS::Tools::XmlDocument.parse(response)
          end

        end
      end
    end
  end
end