# encoding: utf-8

require 'parslet'

require_relative 'basic_parser'
require_relative 'marc_rules'

module Libis
  module Tools
    module Metadata

      # noinspection RubyResolve
      class MarcFormatParser < Libis::Tools::Metadata::BasicParser
        include Libis::Tools::Metadata::MarcRules

        root(:mapping)

        rule(:mapping) { entry.repeat(1).as(:entry) >> postfix?.as(:postfix) }

        rule(:entry) { group.as(:group) | sf_reference }
        rule(:group) { prefix?.as(:prefix) >> grouped(mapping) }

        # pre- and postfix
        rule(:prefix) { other.repeat(1) }
        rule(:prefix) { text }
        rule(:prefix?) { prefix.maybe }
        rule(:postfix) { other.repeat(1) }
        rule(:postfix) { text }
        rule(:postfix?) { postfix.maybe }

        # subfield reference
        rule(:sf_reference) { sf_variable.as(:subfield) | sf_fixed.as(:fixfield) }

        rule(:sf_variable) { prefix?.as(:prefix) >> sf_indicator >> sf_repeat?.as(:repeat) >> sf_name }
        rule(:sf_repeat) { star >>
            (dquote >> not_dquote.repeat.as(:separator) >> dquote |
                squote >> not_squote.repeat.as(:separator) >> squote
            ).maybe
        }
        rule(:sf_repeat?) { sf_repeat.maybe }

        rule(:sf_fixed) { prefix?.as(:prefix) >> sf_indicator >> str('@') >> (sf_position | sf_range | sf_star) }
        rule(:sf_position) { lsparen >> integer.as(:position) >> rsparen }
        rule(:sf_range) { lsparen >> integer.as(:first) >> minus >> integer.as(:last) >> rsparen }
        rule(:sf_star) { star.as(:all) }

        rule(:other) { paren.absent? >> dollar.absent? >> any | str('$$') }
      end

    end
  end
end
