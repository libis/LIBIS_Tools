# encoding: utf-8
require_relative '../spec_helper'
require 'libis/tools/metadata/parser/marc21_parser'
require 'parslet/convenience'
require 'pp'

require_relative 'marc21_parser_data'

describe 'MARC 21 parser' do
  subject(:parser) { Libis::Tools::Metadata::Marc21Parser.new }

  context 'Syntax parser' do

    marc21_parser_testdata.each do |expectation|

      next unless expectation.has_key?(:tree)

      if expectation[:tree] != :failure
        it "parses #{expectation[:title]}" do
          expect {
            # noinspection RubyArgCount,RubyUnusedLocalVariable
            tree = parser.select.parse(expectation[:input]) if expectation[:title] =~ /^select /
            # noinspection RubyArgCount,RubyUnusedLocalVariable
            tree = parser.format.parse(expectation[:input]) if expectation[:title] =~ /^format /
            # pp tree
            expect(tree).to be_a Hash
            expect(tree).to match expectation[:tree]
          }.to_not raise_error
        end
      else
        it "does not parse #{expectation[:title]}" do
          expect {
            # noinspection RubyArgCount,RubyUnusedLocalVariable
            tree = parser.select.parse(expectation[:input]) if expectation[:title] =~ /^select /
            # noinspection RubyArgCount,RubyUnusedLocalVariable
            tree = parser.format.parse(expectation[:input]) if expectation[:title] =~ /^format /
            # pp tree
          }.to raise_error(Parslet::ParseFailed)
        end
      end

    end
  end

  context 'Transformer' do

    let(:transformer) { parser.transformer }

    it 'can be created' do
      expect(transformer).to be_a Libis::Tools::Metadata::Marc21Parser::Transformer
    end

    marc21_parser_testdata.each do |expectation|

      next unless expectation.has_key?(:transform)

      it "transforms #{expectation[:title]}" do
        tree = parser.parse(expectation[:input])
        # pp tree
        expect(transformer.apply(tree)).to eq expectation[:transform]
      end

    end

  end

end