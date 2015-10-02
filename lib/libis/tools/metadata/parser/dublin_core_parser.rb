# encoding: utf-8

require 'parslet'

require_relative 'basic_parser'

module Libis
  module Tools
    module Metadata

      # noinspection RubyResolve
      class DublinCoreParser < Libis::Tools::Metadata::BasicParser
        rule(:namespace) { match('[^:]').repeat(1).as(:namespace) >> str(':') }
        rule(:namespace?) { namespace.maybe }

        rule(:attribute) { namespace? >> name_string.as(:name) >> str('=') >> str('"') >> match('[^"]').repeat(1).as(:value) >> str('"') }
        rule(:attributes) { attribute >> (spaces >> attribute).repeat }
        rule(:attributes?) { attributes.maybe }
        rule(:element) { name_string.as(:element) }
        rule(:DC) { namespace >> element >> (spaces >> attributes.as(:attributes)).maybe }

        root(:DC)

        def to_target(tree)
          tree = tree[:DC]
          return nil unless tree
          result = "xml['#{tree[:namespace]}'].#{tree[:element]}("
          tree[:attributes].each { |attribute| result += "'#{attribute[:name]}' => '#{attribute[:value]}'" }
          result + ').text'
        end

      end

    end
  end
end
