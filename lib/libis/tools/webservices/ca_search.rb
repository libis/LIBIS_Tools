# coding: utf-8

require_relative 'ca_connector'

module LIBIS
  module Tools
    module Webservices

      class CaSearch < CaConnector

        def initialize(host = nil)
          super 'Search', host
        end

        def query(query, type = nil)
          type ||= 'ca_objects'
          request :querySoap, type: type, query: query
        end

      end

    end
  end
end
