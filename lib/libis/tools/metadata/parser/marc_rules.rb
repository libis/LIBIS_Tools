# encoding: utf-8

require 'parslet'

module Libis
  module Tools
    module Metadata

      # noinspection RubyResolve
      module MarcRules
        include Parslet

        # tag
        rule(:tag) { tag_numeric | tag_alpha }
        rule(:tag_numeric) { number.repeat(3, 3) }
        rule(:tag_alpha) { character.repeat(3, 3) }

        # indicator
        rule(:indicator) { hashtag | underscore | number | character }
        rule(:indicator?) { indicator.maybe }
        rule(:indicators) { indicator?.as(:ind1) >> indicator?.as(:ind2) }

        # subfield
        rule(:sf_indicator) { dollar }
        rule(:sf_name) { (character | number).as(:name) }
        rule(:sf_name?) { sf_name.maybe }
        rule(:sf_names) { (character | number).repeat(1).as(:names) }
        rule(:sf_names?) { sf_names.maybe }
        rule(:subfield) { sf_indicator >> sf_name }

      end

    end
  end
end
