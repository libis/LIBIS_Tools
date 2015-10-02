# encoding: utf-8

require 'simple_xlsx_reader'
require 'backports/rails/string'

require_relative 'parsers'

module Libis
  module Tools
    module Metadata

      # noinspection RubyResolve
      class Mapper

        attr_reader :target_parser, :selection_parser, :format_parser
        attr_reader :tables, :mapping

        def initialize(selection_parser, target_parser, format_parser, config_xlsx)
          @selection_parser = selection_parser
          @target_parser = target_parser
          @format_parser = format_parser
          @mapping = []
          @tables = {}
          doc = SimpleXlsxReader.open(config_xlsx)
          doc.sheets.each do |sheet|
            if sheet.name == 'Mapping'
              mapping = sheet_to_hash(sheet)
              mapping.each do |rule|
                @mapping << {
                    'Selection' => begin
                      selection_parser.parse(rule['Selection'])
                    rescue Parslet::ParseFailed => error
                      puts "Error parsing '#{rule['Selection']}'"
                      puts error.cause.ascii_tree
                    end,
                    'Target' => begin
                      target_parser.parse(rule['Target'])
                    rescue Parslet::ParseFailed => error
                      puts "Error parsing '#{rule['Target']}'"
                      puts error.cause.ascii_tree
                    end,
                    'Format' => begin
                      format_parser.parse(rule['Format'])
                    rescue Parslet::ParseFailed => error
                      puts "Error parsing '#{rule['Format']}'"
                      puts error.cause.ascii_tree
                    end,
                }
              end
            else
              @tables[sheet.name] = sheet_to_hash(sheet)
            end
          end
          if @mapping.empty?
            raise RuntimeError, "Failure: config file '#{config_xlsx}' does not contain a 'Mapping' sheet."
          end
        end

        private

        def sheet_to_hash(sheet)
          data = sheet.rows
          header = data.shift
          result = []
          data.each do |row|
            x = {}
            header.each_with_index { |col_name, col_index| x[col_name] = row[col_index] }
            result << x
          end
          result
        end

        def lookup(table, key, constraints = {})
          @tables[table].select { |value| constraints.map { |k, v| value[k] == v }.all? }.map { |v| v[key] }
        end

      end
    end
  end
end
