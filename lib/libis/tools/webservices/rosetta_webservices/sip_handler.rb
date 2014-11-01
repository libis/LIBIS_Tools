# encoding: utf-8

require 'libis/tools/webservices/rosetta_webservices/client'
require 'libis/tools/extend/hash'

module LIBIS
  module Tools
    module Webservices
      module RosettaServices

        class SipHandler < LIBIS::Tools::Webservices::RosettaServices::Client

          def initialize(base_url = 'http://depot.lias.be')
            super 'repository', 'SipWebServices', base_url
          end

          def get_info(sip_id)
            request :get_sip_status_info, arg0: sip_id
          end

          def get_ies(sip_id)
            (request :get_sip_i_es, arg0: sip_id).split(',')
          end

        end
      end
    end
  end
end