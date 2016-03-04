# encoding: utf-8

require 'parslet'
require 'parslet/convenience'

module Libis
  module Tools
    module Metadata
      # noinspection RubyResolve

      # New style parsers and converters for metadata. New, not finished and untested.
      class BasicParser < Parslet::Parser
        # space
        rule(:space) { match('\s') }
        rule(:space?) { space.maybe }
        rule(:spaces) { space.repeat(1) }
        rule(:spaces?) { space.repeat }

        # numbers
        rule(:number) { match('[0-9]') }
        rule(:number?) { number.maybe }
        rule(:integer) { number.repeat(1) }

        # chars
        rule(:character) { match(/[a-z]/i) }
        rule(:character?) { character.maybe }
        rule(:characters) { character.repeat(1) }

        # word
        rule(:wordchar) { match('\w') }

        # name
        rule(:name_string) { ((character | underscore) >> wordchar.repeat).repeat(1) }

        # text
        rule(:other) { not_paren }
        rule(:text) { other.repeat(1) }
        rule(:text?) { text.maybe }

        # special chars
        rule(:minus) { str('-') }
        rule(:colon) { str(':') }
        rule(:semicolon) { str(';') }
        rule(:underscore) { str('_') }
        rule(:hashtag) { str('#') }
        rule(:dollar) { str('$') }
        rule(:star) { str('*') }

        # grouping
        rule(:paren) { lparen | rparen }
        rule(:lparen) { lrparen | lsparen | lcparen | squote | dquote }
        rule(:rparen) { rrparen | rsparen | rcparen | squote | dquote }

        rule(:not_paren) { paren.absent? >> any }
        rule(:not_lparen) { lrparen.absent? >> lsparen.absent? >> lcparen.absent? >> squote.absent? >> dquote.absent? >> any }
        rule(:not_rparen) { rrparen.absent? >> rsparen.absent? >> rcparen.absent? >> squote.absent? >> dquote.absent? >> any }

        rule(:lrparen) { str('(') }
        rule(:lsparen) { str('[') }
        rule(:lcparen) { str('{') }
        rule(:rrparen) { str(')') }
        rule(:rsparen) { str(']') }
        rule(:rcparen) { str('}') }

        rule(:squote) { str("'") }
        rule(:dquote) { str('"') }
        rule(:quote) { squote | dquote }

        rule(:not_squote) { squote.absent? >> any }
        rule(:not_dquote) { dquote.absent? >> any }
        rule(:not_quote) { quote.absent? >> any }

        def complement(char)
          case char
            when '('
              ')'
            when '{'
              '}'
            when '['
              ']'
            else
              char
          end
        end

        def grouped(foo, left_paren = lparen)
          scope {
            left_paren.capture(:paren).as(:lparen) >>
                foo >>
                dynamic { |_, c| str(complement(c.captures[:paren])) }.as(:rparen)
          }
        end

        def grouped_anonymous(foo, left_paren = lparen)
          scope {
            left_paren.capture(:paren) >>
                foo >>
                dynamic { |_, c| str(complement(c.captures[:paren])) }
          }
        end

        def any_quoted(key = :text)
          scope {
            quote.capture(:quote) >>
                dynamic { |_, c| (str(c.captures[:quote]).absent? >> any).repeat(1) }.maybe.as(key) >>
                dynamic { |_, c| str(c.captures[:quote]) }
          }
        end

        def transformer
          self.class::Transformer.new rescue nil
        end

      end

    end
  end
end


