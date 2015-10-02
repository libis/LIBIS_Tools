# encoding: utf-8

require 'parslet'

require_relative 'basic_parser'
require_relative 'marc_rules'

module Libis
  module Tools
    module Metadata

      # noinspection RubyResolve
      class Marc21Parser < Libis::Tools::Metadata::BasicParser

        root(:marc21)
        rule(:marc21) { select.as(:select) | format.as(:format) }

        # select syntax
        rule(:select) do
          str('MARC') >>
              spaces? >> tag.as(:tag) >>
              spaces? >> indicator.maybe.as(:ind1) >> indicator.maybe.as(:ind2) >>
              spaces? >> subfield.maybe.as(:subfield) >>
              spaces? >> condition.maybe.as(:condition)
        end
        rule(:condition) { grouped_anonymous(cond_format.as(:cond_format)) }
        rule(:cond_format) { cond_entry.repeat(1).maybe.as(:entry) >> postfix.maybe.as(:postfix) }
        rule(:cond_entry) { sf_reference | method_call | cond_group }
        rule(:cond_group) { (prefix.maybe.as(:prefix) >> grouped(cond_format)).as(:cond_group) }

        # Formatting syntax
        rule(:format) { entry.repeat(1).maybe.as(:entry) >> postfix.maybe.as(:postfix) }

        rule(:entry) { sf_reference | method_call | group }
        # noinspection RubyArgCount
        rule(:group) { (prefix.maybe.as(:prefix) >> grouped(format)).as(:group) }
        # noinspection RubyArgCount
        rule(:method_call) { (prefix.maybe.as(:prefix) >> sf_indicator >> grouped_anonymous(format, lrparen)).as(:method_call) }

        # pre- and postfix
        rule(:prefix) { other.repeat(1) }
        rule(:prefix) { text }
        rule(:postfix) { other.repeat(1) }
        rule(:postfix) { text }

        # subfield reference
        rule(:sf_reference) { sf_variable.as(:subfield) | sf_fixed.as(:fixfield) }

        rule(:sf_variable) { prefix.maybe.as(:prefix) >> sf_indicator >> sf_repeat.maybe.as(:repeat) >> sf_name }
        rule(:sf_repeat) { star >> any_quoted(:separator).maybe }

        rule(:sf_fixed) { prefix.maybe.as(:prefix) >> sf_indicator >> lsparen >> (sf_range | sf_position | sf_star) >> rsparen }
        rule(:sf_star) { star.as(:all) }
        rule(:sf_position) { integer.as(:position) }
        rule(:sf_range) { integer.as(:first) >> minus >> integer.as(:last) }

        rule(:other) { paren.absent? >> dollar.absent? >> any | litteral_dollar }

        # tag
        rule(:tag) { tag_numeric | tag_alpha }
        rule(:tag_numeric) { number.repeat(3, 3) }
        rule(:tag_alpha) { character.repeat(3, 3) }

        # indicator
        rule(:indicator) { hashtag | underscore | number | character }

        # subfield
        rule(:sf_indicator) { dollar }
        rule(:sf_name) { (character | number).as(:name) }
        rule(:sf_names) { (character | number).repeat(1).as(:names) }
        rule(:subfield) { sf_indicator >> sf_name }
        rule(:litteral_dollar) { dollar >> dollar }

        # noinspection RubyResolve
        class Transformer < Parslet::Transform
          rule(name: simple(:name)) { "#{name}" }
          # select transformation rules
          rule(cond_group: {
                   prefix: simple(:prefix),
                   lparen: simple(:lparen),
                   entry: simple(:entry),
                   postfix: simple(:postfix),
                   rparen: simple(:rparen)}) {
            "#{prefix}#{lparen}#{entry}#{postfix}#{rparen}"
          }
          rule(cond_group: {
                   prefix: simple(:prefix),
                   lparen: simple(:lparen),
                   entry: sequence(:entry),
                   postfix: simple(:postfix),
                   rparen: simple(:rparen)}) {
            "#{prefix}#{lparen}#{entry.join}#{postfix}#{rparen}"
          }
          rule(cond_format: {
                   entry: sequence(:entry),
                   postfix: simple(:postfix)
               }) { ", Proc.new { |f| #{entry.join}#{postfix} }" }
          rule(select: {
                   tag: simple(:tag),
                   ind1: simple(:ind1),
                   ind2: simple(:ind2),
                   subfield: simple(:subfield),
                   condition: simple(:condition)
               }) { "record.select_fields('#{tag}#{ind1 || '#'}#{ind2 || '#'}#{subfield}'#{condition || ''})" }
          # format transformation rules
          rule(format: {
                   entry: sequence(:entries),
                   postfix: simple(:postfix)
               }) do
            if entries.size == 1 && postfix.nil?
              entries.first
            else
              "field_format(#{entries.join(',')}#{", postfix: '#{postfix}'" if postfix}).to_s"
            end
          end
          rule(group: {
                   prefix: simple(:prefix),
                   lparen: simple(:lparen),
                   entry: nil,
                   postfix: simple(:postfix),
                   rparen: simple(:rparen)}) {
            "#{prefix}#{lparen}#{postfix}#{rparen}"
          }
          rule(group: {
                   prefix: simple(:prefix),
                   lparen: simple(:lparen),
                   entry: '',
                   postfix: simple(:postfix),
                   rparen: simple(:rparen)}) {
            "#{prefix}#{lparen}#{postfix}#{rparen}"
          }
          rule(group: {
                   prefix: simple(:prefix),
                   lparen: simple(:lparen),
                   entry: simple(:entry),
                   postfix: simple(:postfix),
                   rparen: simple(:rparen)}) {
            "field_format(#{entry}#{", prefix: '#{prefix}#{lparen}'" if prefix || lparen}#{", postfix: '#{postfix}#{rparen}'" if postfix || rparen}).to_s"
          }
          rule(group: {
                   prefix: simple(:prefix),
                   lparen: simple(:lparen),
                   entry: sequence(:entries),
                   postfix: simple(:postfix),
                   rparen: simple(:rparen)}) {
            "field_format(#{entries.join(',')}#{", prefix: '#{prefix}#{lparen}'" if prefix || lparen}#{", postfix: '#{postfix}#{rparen}'" if postfix || rparen}).to_s"
          }
          rule(fixfield: {
                   prefix: nil,
                   all: '*'
               }) { 'f[]' }
          rule(fixfield: {
                   prefix: simple(:prefix),
                   all: '*'
               }) { "field_format(f[], prefix: '#{prefix}').to_s" }
          rule(fixfield: {
                   prefix: nil,
                   position: simple(:position)
               }) { "f[#{position}]" }
          rule(fixfield: {
                   prefix: simple(:prefix),
                   position: simple(:position)
               }) do
            if prefix
              "field_format(f[#{position}], prefix: '#{prefix}').to_s"
            else
              "f[#{position}]"
            end
          end
          rule(fixfield: {
                   prefix: nil,
                   first: simple(:from),
                   last: simple(:to)
               }) { "f[#{from},#{to}]" }
          rule(fixfield: {
                   prefix: simple(:prefix),
                   first: simple(:from),
                   last: simple(:to)
               }) { "field_format(f[#{from},#{to}], prefix: '#{prefix}').to_s" }
          rule(subfield: {
                   prefix: simple(:prefix),
                   repeat: nil,
                   name: simple(:name),
               }) { "field_format(f.subfield('#{name}'), prefix: '#{prefix}').to_s" }
          rule(subfield: {
                   prefix: simple(:prefix),
                   repeat: {separator: simple(:separator)},
                   name: simple(:name),
               }) { "field_format(f.subfield_array('#{name}')#{", prefix: '#{prefix}'" if prefix}, join: '#{separator}').to_s" }
          rule(subfield: {
                   prefix: simple(:prefix),
                   repeat: '*',
                   name: simple(:name),
               }) { "field_format(f.subfield_array('#{name}')#{", prefix: '#{prefix}'" if prefix}, join: ';').to_s" }
          rule(subfield: {
                   prefix: nil,
                   repeat: nil,
                   name: simple(:name),
               }) { "f.subfield('#{name}')" }
        end

      end

    end
  end
end
