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
      #   first row, will be used as header values, ignoring the rest of the Hash. A key of :header_search
      #   Default is empty array, meaning to use whatever is on the first row as header.
      # - optional: a list of headers that may be present, but are not required. Similar format as above. Default is
      #   empty array
      # - extension: :csv, :xlsx, :xlsm, :ods, :xls, :google to help the library in deciding what format the file is in.
      #
      # The following options are only applicable to CSV input files and are ignored otherwise.
      # - encoding: the encoding of the CSV file. e.g. 'windows-1252:UTF-8' to convert the input from windows code page
      #   1252 to UTF-8 during file reading
      # - col_sep: column separator. Default is ',', but can be set to "\t" for TSV files.
      # - quote_char: character for quoting.
      #
      # Resources are created during initialisation and should be freed by calling the #close method.
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
            skip_headers: true,
            force_headers: true,
        }.merge(opts)

        required_headers = options.delete(:required) || []
        optional_headers = options.delete(:optional) || []

        file, sheet = file_name.split('|')
        @ss = ::Roo::Spreadsheet.open(file, options)
        @ss.default_sheet = sheet if sheet

        check_headers(required_headers, optional_headers)

      end

      # Iterate over sheet content.
      #
      # The options Hash can contain the following keys:
      # - :sheet - overwrites default sheet name
      # - :required - Array or Hash of required headers
      # - :optional - Array or Hash of optional headers
      #
      # Each iteration, a Hash will be passed with the key names as specified in the header options and the
      # corresponding cell values.
      #
      # @param [Hash] options
      def each(options = {}, &block)
        @ss.default_sheet = options[:sheet] if options[:sheet]
        @ss.each(check_headers(options[:required], options[:optional]), &block)
      end

      def parse(options = {})
        @ss.default_sheet = options[:sheet] if options[:sheet]
        @ss.parse(check_headers(options[:required], options[:optional]))
      end

      def shift
        return nil unless @current_row < @ss.last_row
        @current_row += 1
        Hash[@ss.row(@current_row).map.with_index { |v, i| [headers[i], v] }]
      end

      # Open and iterate over sheet content.
      #
      # @param @see #initialize
      def self.foreach(file_name, opts = {}, &block)
        Libis::Tools::Spreadsheet.new(file_name, opts).each(&block)
      end

      def headers
        (@ss.headers || {}).keys + @extra_headers
      end

      private

      def check_headers(required_headers, optional_headers)
        return @header_options unless required_headers || optional_headers
        header_options = {}
        required_headers ||= []
        optional_headers ||= []
        unless required_headers.is_a?(Hash) || required_headers.is_a?(Array)
          raise RuntimeError, 'Required headers should be either a Hash or an Array.'
        end
        unless optional_headers.is_a?(Hash) || optional_headers.is_a?(Array)
          raise RuntimeError, 'Optional headers should be either a Hash or an Array.'
        end
        if required_headers.empty?
          if optional_headers.empty?
            header_options[:headers] = :first_row
          else
            header_options[:header_search] =
                (optional_headers.is_a?(Hash) ? optional_headers.values : optional_headers)
          end
        else
          header_options =
              required_headers.is_a?(Hash) ? required_headers : Hash[required_headers.map { |x| [x] * 2 }]
          header_options.merge!(
              optional_headers.is_a?(Hash) ? optional_headers : Hash[optional_headers.map { |x| [x] * 2 }]
          )
        end

        required_headers = required_headers.values if required_headers.is_a?(Hash)

        @ss.each(header_options) { break }
        @current_row = @ss.header_line

        # checks
        found_headers = required_headers & @ss.row([@current_row, 1].max)
        if found_headers.empty?
          # No headers found - check if there are enough columns to satisfy the required headers
          if required_headers.size > (@ss.last_column - @ss.first_column) + 1
            raise RuntimeError, 'Sheet does not contain enough columns.'
          end
        elsif found_headers.size < required_headers.size
          # Some, but not all headers found
          raise RuntimeError, "Headers not found: #{required_headers - found_headers}."
        else
          # All required headers found
        end

        @extra_headers = (required_headers.empty? && optional_headers.empty?) ? [] :
            @ss.row(@ss.header_line).keep_if { |x| x && !header_options.values.include?(x) }

        @header_options = header_options.merge(Hash[@extra_headers.map { |v| [v] * 2 }])
      end

    end

  end
end