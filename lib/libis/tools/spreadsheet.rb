require 'libis/tools/extend/roo'
require 'libis/tools/extend/hash'
require 'awesome_print'

module Libis
  module Tools

    class Spreadsheet

      # Spreadsheet reader.
      #
      # This class supports CSV, Excel 2007-2016, Excel (pre-2007), LibreOffice/OpenOffice Calc and Google spreadsheets
      # thanks to the Roo (http://github.com/roo-rb/roo) project.
      #
      # The first argument is the file name to read. For spreadsheets, append '|' and the sheet name to specify the
      # sheet to read.
      #
      # The second argument is a Hash with options. The options can be:
      # - required: a list of headers that need to be present. The list can be an Array containing the litteral header
      #   values expected. Alternatively, a Hash is also allowed with alternative header names as keys and litteral
      #   names as values. If a :headers keys is present in the Hash with a value of true or :first, whatever is on the
      #   first row, will be used as header values, ignoring the rest of the Hash. A key of :header_search with an array
      #   of strings as value will search for a row that contains each of the strings in the given array. Each string is
      #   searched by regular expression, so strings may contain wildcards.
      #   Default is empty array, meaning to use whatever is on the first row as header.
      # - optional: a list of headers that may be present, but are not required. Similar format as above. Default is
      #   empty array.
      # - noheader: a list of headers to force upon the sheet if no headers are present.
      # - extension: :csv, :xlsx, :xlsm, :ods, :xls, :google to help the library in deciding what format the file is in.
      #
      # The following options are only applicable to CSV input files and are ignored otherwise.
      # - encoding: the encoding of the CSV file. e.g. 'windows-1252:UTF-8' to convert the input from windows code page
      #   1252 to UTF-8 during file reading
      # - col_sep: column separator. Default is ',', but can be set to "\t" for TSV files.
      # - quote_char: character for quoting.
      #
      # @param [String] file_name
      # @param [Hash] opts
      def initialize(file_name, opts = {})
        options = {
            csv_options: [:encoding, :col_sep, :quote_char].inject({}) do |h, k|
              h[k] = opts.delete(k) if opts[k]
              h
            end.merge(
                encoding: 'UTF-8',
                col_sep: ',',
                quote_char: '"',
            ),
        }.merge(opts)

        required_headers = options.delete(:required) || []
        optional_headers = options.delete(:optional) || []
        noheader_headers = options.delete(:noheader) || []

        file, sheet = file_name.split('|')
        @ss = ::Roo::Spreadsheet.open(file, options)
        @ss.default_sheet = sheet if sheet

        @header_options = {}

        check_headers(required: required_headers, optional: optional_headers, noheader: noheader_headers)

      end

      # Iterate over sheet content.
      #
      # The options Hash can contain the following keys:
      # - :sheet - overwrites default sheet name
      # - :required - Array or Hash of required headers
      # - :optional - Array or Hash of optional headers
      # - :noheader - Array of noheader headers
      #
      # Each iteration, a Hash will be passed with the key names as specified in the header options and the
      # corresponding cell values.
      #
      # @param [Hash] options
      def each(options = {}, &block)
        @ss.default_sheet = options[:sheet] if options[:sheet]
        @ss.each(check_headers(options), &block)
      end

      # Parse sheet content.
      #
      # The options Hash can contain the following keys:
      # - :sheet - overwrites default sheet name
      # - :required - Array or Hash of required headers
      # - :optional - Array or Hash of optional headers
      # - :noheader - Array of noheader headers
      #
      # An Array will be returned with for each row a Hash with the key names as specified in the header options and the
      # corresponding cell values.
      #
      # @param [Hash] options
      # @return [Array<Hash>]
      def parse(options = {})
        @ss.default_sheet = options.delete(:sheet) if options.has_key?(:sheet)
        @ss.parse(check_headers(options))
      end

      # Return the current row and increment the current_row pointer.
      def shift
        return nil unless @current_row < @ss.last_row
        @current_row += 1
        Hash[@ss.row(@current_row).map.with_index { |v, i| [headers[i], v] }]
      end

      # Set the current_row pointer back to the start
      def restart
        @current_row = @ss.header_line
      end

      # Open and iterate over sheet content.
      #
      # @param @see #initialize
      def self.foreach(file_name, opts = {}, &block)
        Libis::Tools::Spreadsheet.new(file_name, opts).each(&block)
      end

      def headers
        (@ss.headers || {}).keys
      end

      private

      def check_headers(options = {})
        if options[:required] || options[:optional] || options[:noheader]

          # defaults
          ss_options = {}
          required_headers = options[:required] || []
          optional_headers = options[:optional] || []

          # make sure required_headers is a Hash
          case required_headers
            when Hash
              # OK
            when Array
              required_headers = Hash[required_headers.zip(required_headers)]
            else
              raise RuntimeError, 'Required headers should be either a Hash or an Array.'
          end

          # make sure optional_headers is a Hash
          case optional_headers
            when Hash
              # OK
            when Array
              optional_headers = Hash[optional_headers.zip(optional_headers)]
            else
              raise RuntimeError, 'Optional headers should be either a Hash or an Array.'
          end

          # make sure noheader_headers is properly intialized
          noheader_headers = options[:noheader]
          raise RuntimeError, 'Noheader headers should be an Array.' unless noheader_headers.is_a?(Array)

          # if not set, default to both required and optional headers
          noheader_headers = (required_headers.keys + optional_headers.keys) if noheader_headers.empty?

          # force noheader_headers or just use first row
          ss_options[:headers] = noheader_headers.empty? ? :first_row : noheader_headers

          # search for whatever whas supplied
          ss_options.merge!(required_headers).merge!(optional_headers)

          # allow partial match for only required headers
          ss_options[:partial_match] = true
          ss_options[:required_headers] = required_headers.keys

          # force a header check (may throw exceptions)
          begin
            @ss.each(ss_options.dup) { break }
          rescue Roo::HeaderRowNotFoundError
            found_headers = required_headers.keys & @ss.headers.keys
            raise RuntimeError, "Headers not found: #{required_headers.keys - found_headers}."
          rescue Roo::HeaderRowIncompleteError
            if @ss.row(@ss.header_line).compact.empty?
              raise RuntimeError, 'Sheet does not contain enough columns.'
            else
              found_headers = required_headers.keys & @ss.headers.keys
              raise RuntimeError, "Headers not found: #{required_headers.keys - found_headers}."

            end
          end

          @current_row = @ss.header_line
          @header_options = ss_options.merge(skip_headers: true)
        end

        @header_options.dup
      end

    end

  end
end