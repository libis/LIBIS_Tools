require 'roo'
require 'roo-xls'
require 'roo-google'

module Roo
  class HeaderRowIncompleteError < Error;
  end
  class Base

    def each(options = {})
      return to_enum(:each, options) unless block_given?

      if options.empty?
        1.upto(last_row) do |line|
          yield row(line)
        end
      else
        clean_sheet_if_need(options)
        search_or_set_header(options)
        headers = @headers ||
            Hash[(first_column..last_column).map do |col|
              [cell(@header_line, col), col]
            end]

        start_line = @header_line || 1
        start_line = (@header_line || 0) + 1 if @options[:skip_headers]
        start_line.upto(last_row) do |line|
          yield(Hash[headers.map { |k, v| [k, cell(line, v)] }])
        end
      end
    end

    private

    def row_with(query, return_headers = false)
      line_no = 0
      each do |row|
        line_no += 1
        headers = query.map { |q| row.grep(q)[0] }.compact

        if headers.length == query.length
          @header_line = line_no
          return return_headers ? headers : line_no
        elsif line_no > 100
          raise Roo::HeaderRowNotFoundError
        elsif headers.length > 0
          # partial match
          @header_line = line_no
          raise Roo::HeaderRowIncompleteError unless @options[:force_headers]
          return return_headers ? headers : line_no
        end
      end
      raise Roo::HeaderRowNotFoundError
    end

    def search_or_set_header(options)
      if options[:header_search]
        @headers = nil
        @header_line = row_with(options[:header_search])
      elsif [:first_row, true].include?(options[:headers])
        @headers = Hash[row(first_row).map.with_index{ |x, i| [x, i + first_column] }]
        @header_line = first_row
      else
        set_headers(options)
      end
    end

    def set_headers(hash = {})
      # try to find header row with all values or give an error
      # then create new hash by indexing strings and keeping integers for header array
      @headers = row_with(hash.values, true)
      @headers = Hash[hash.keys.zip(@headers.map { |x| header_index(x) })]
    rescue Roo::HeaderRowNotFoundError => e
      if @options[:force_headers]
        # Finding headers failed. Force the headers in the order they are given, but up to the last column
        @headers = {}
        hash.keys.each.with_index { |k, i| @headers[k] = i + first_column if i + first_column <= last_column }
        @header_line = first_row
        @header_line -= 1 unless hash.values.any? { |v| row(1).include? v } # partial match
      else
        raise e
      end
    end

  end
end