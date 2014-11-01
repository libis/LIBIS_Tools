# coding: utf-8

require 'rest_client'
require 'json'
require 'gyoku'

module LIBIS
  module Tools
    module Webservices

      module RestClient
        attr_reader :client

        def configure(url, options = {})
          @client = ::RestClient::Resource.new(url, options)
        end

        def get(path, params = {}, headers = {}, &block)
          response = client[path].get({params: params}.merge headers, &block)
          parse_result response, &block
        end

        def post(path, params = {}, headers = {}, &block)
          response = client[path].post({params: params}.merge headers, &block)
          parse_result response, &block
        end

        protected

        def parse_result(response)
          case response.code.to_i
            when 0..300
              # success, we continue
            else
              # just return the response
              return response
          end

          block_given? ? yield(response) : result_parser(response)
        end

        def result_parser(response)
          response
        end

      end

    end
  end
end
