require 'roo'
require 'roo-xls'
require 'roo-google'
require 'libis/tools/extend/hash'

module Roo
  class HeaderRowIncompleteError < Error;
  end
  class Base

    # changes:
    # - added option :skip_header to prevent #each and #parse to return the header row
    # - added option :partial_match to allow to use headers that only partially match the query
    # - added option :required to force the result to have at least these columns
    # - allow option :headers to contain an array with header labels that will be forced when no header row is found
    # - improved proper range scanning (first_row->last_row and first_column->last_column)

    attr_accessor :partial_match

    def each(options = {})
      return to_enum(:each, options) unless block_given?

      skip_headers = options.delete(:skip_headers)
      @partial_match = options.delete(:partial_match) if options.has_key?(:partial_match)
      required_headers = options.delete(:required_headers) if options.has_key?(:required_headers)

      if options.empty?
        first_row.upto(last_row) do |line|
          next if skip_headers && line == header_line
          yield row(line)
        end
      else
        clean_sheet_if_need(options)
        @headers = search_or_set_header(options)
        if required_headers
          raise Roo::HeaderRowIncompleteError unless headers.keys & required_headers == required_headers
        end

        start_line = header_line
        start_line += 1 if skip_headers
        start_line.upto(last_row) do |line|
          yield(Hash[headers.map { |k, v| [k, cell(line, v)] }])
        end
      end
    end

    private

    def row_with(query)
      line_no = first_row
      each do |row|
        headers = query.map { |q| row.grep(q)[0] }.compact

        if headers.length == query.length
          @header_line = line_no
          return headers
        elsif line_no > 100
          raise Roo::HeaderRowNotFoundError
        elsif headers.length > 0
          # partial match
          @header_line = line_no
          raise Roo::HeaderRowIncompleteError unless partial_match
          return headers
        end
        line_no += 1
      end
      raise Roo::HeaderRowNotFoundError
    end

    def search_or_set_header(options)
      force_headers = options.delete(:headers)
      if options[:header_search]
        row_with(options[:header_search])
      elsif [:first_row, true].include?(force_headers)
        @header_line = first_row
      else
        return set_headers(options)
      end
      return Hash[row(header_line).map { |x| [x, header_index(x)] }]
    rescue Roo::HeaderRowNotFoundError => e
      # Not OK unless a list of headers is supplied
      raise e unless force_headers.is_a?(Array)
      # Force the headers in the order they are given, but up to the last column
      @header_line = first_row - 1
      return Hash[force_headers.zip(first_column..last_column)].cleanup
    end

    def set_headers(hash)
      # try to find header row with all values or give an error
      # then create new hash by indexing strings and keeping integers for header array
      row_with(hash.values)
      positions = Hash[row(header_line).map { |x| [x, header_index(x)] }]
      Hash[positions.map { |k, v| [hash.invert[k] || k, v] }]
    end

  end
end