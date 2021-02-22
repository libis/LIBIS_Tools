require 'csv'

module Libis
  module Tools
    module Csv

      # @param [String] file_name
      # @param [Hash] options
      # @return [CSV] Open CSV object
      def self.open(file_name, options = {})
        options = {
            mode: 'rb:UTF-8',
            required: %w'',
            optional: %w'',
            col_sep: ',',
            quote_char: '"'
        }.merge options
        mode = options.delete(:mode)
        required_headers = options.delete(:required)
        optional_headers = options.delete(:optional)
        options[:headers] = true
        options[:return_headers] = true
        csv = ::CSV.open(file_name, mode, options)
        line = csv.shift
        found_headers = required_headers & line.headers
        return csv if found_headers.size == required_headers.size
        raise RuntimeError, "CSV headers not found: #{required_headers - found_headers}" unless found_headers.empty?
        csv.close
        options[:headers] = (required_headers + optional_headers)[0...line.size]
        raise RuntimeError, 'CSV does not contain enough columns' if required_headers.size > line.size
        options[:return_headers] = true
        csv = ::CSV.open(file_name, mode, options)
        csv.shift
        csv
      end
    end
  end
end