# encoding: utf-8

require 'libis/tools/webservices/rosetta_webservices/client'
require 'libis/tools/extend/hash'

module LIBIS
  module Tools
    module Webservices
      module RosettaServices

        class ProducerHandler < LIBIS::Tools::Webservices::RosettaServices::Client

          def initialize(base_url = 'http://depot.lias.be')
            super 'deposit', 'ProducerWebServices', base_url
          end

          def get_user_id(name)
            request :get_internal_user_id_by_external_id, arg0: name
          end

        end
      end
    end
  end
end