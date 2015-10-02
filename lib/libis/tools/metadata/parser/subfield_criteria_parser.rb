# encoding: utf-8

require 'parslet'

require_relative 'basic_parser'

module Libis
  module Tools
    module Metadata

      # noinspection RubyResolve
      class SubfieldCriteriaParser < Libis::Tools::Metadata::BasicParser

        root(:criteria)

        rule(:criteria) { selection >> (spaces >> selection).repeat }

        rule(:selection) { must >> must_not.maybe }

        rule(:must) { names.as(:must).maybe >> (one_of | only_one_of).maybe }
        rule(:must_not) { minus >> must.as(:not) }

        rule(:one_of) { lrparen >> names.as(:one_of) >> rrparen }
        rule(:only_one_of) { lcparen >> names.as(:only_one_of) >> rcparen }

        rule(:names) { (character | number).repeat(1) }

        def criteria_to_s(criteria)
          case criteria
            when Array
              # leave as is
            when Hash
              criteria = [criteria]
            else
              return criteria
          end
          criteria.map { |selection| selection_to_s(selection) }.join(' ')
        end

        def selection_to_s(selection)
          return selection unless selection.is_a? Hash
          result = "#{selection[:must]}"
          result += "(#{selection[:one_of]})" if selection[:one_of]
          result += "{#{selection[:only_one_of]}}" if selection[:only_one_of]
          result += "-#{selection_to_s(selection[:not])}" if selection[:not]
          result
        end

        def match_criteria(criteria, data)
          tree = self.new.parse(criteria)
          return true if tree.is_a? String
          tree = [tree] unless tree.is_a? Array
          tree.map { |selection| match_selection(selection, data) }.any?
        end

        def match_selection(selection, data)
          must_match = selection[:must].to_s.split('')
          return false unless must_match == (must_match & data)
          one_of = selection[:one_of].to_s.split('')
          return false unless one_of.empty? || (one_of & data).any?
          only_one_of = selection[:only_one_of].to_s.split('')
          return false unless only_one_of.empty? || (only_one_of & data).size != 1
          return false if match_selection(selection[:not], data) if selection[:not]
          true
        end

      end

    end
  end
end
