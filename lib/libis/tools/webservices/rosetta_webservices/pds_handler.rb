# encoding: utf-8

require 'libis/tools/webservices/rest_client'

module LIBIS
  module Tools
    module Webservices
      module RosettaServices

        class PdsHandler
          include LIBIS::Tools::Webservices::RestClient

          # @param [String] base_url
          def initialize(base_url = 'https://pds.libis.be')
            configure "#{base_url}/pds"
          end

          # @param [String] user
          # @param [String] password
          # @param [String] institute
          # @return [String] PDS handle, nil if could not login
          def login(user, password, institute)
            params = {
                func: 'login',
                calling_system: 'dps',
                login: 'Login',
                bor_id: user,
                bor_verification: password,
                institute: institute
            }
            response = client.put params
            return nil unless response.code == 200 and response.body.match /pds_handle=(\d+)[^\d]/
            $1
          end

          # @param [String] pds_handle
          # @return [Boolean] true if success
          def logout(pds_handle)
            params = {
                func: 'logout',
                cookies: {PDS_HANDLE: pds_handle}
            }
            response = client.get params
            response.code == 200
          end
        end

      end
    end
  end
end
