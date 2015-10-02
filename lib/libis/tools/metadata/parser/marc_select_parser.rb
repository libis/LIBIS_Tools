# encoding: utf-8

require 'parslet'

require_relative 'basic_parser'
require_relative 'marc_rules'

module Libis
  module Tools
    module Metadata

      # noinspection RubyResolve
      class MarcSelectParser < Libis::Tools::Metadata::BasicParser
        include Libis::Tools::Metadata::MarcRules
        root(:MARC)
        rule(:MARC) { str('MARC') >> spaces? >> tag.as(:tag) >> spaces? >> indicators >> spaces? >> subfield.maybe.as(:subfield) }

        # subfield
        # rule(:sf_condition) { sf_indicator >> sf_names >> (space >> sf_names).repeat }
        # rule(:sf_names) { sf_name.repeat(1) }
      end

    end
  end
end
