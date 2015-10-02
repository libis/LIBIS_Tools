# encoding: utf-8
require_relative '../spec_helper'
require 'libis/tools/metadata/parsers'
require 'parslet'
require 'parslet/convenience'
require 'pp'

$DEBUG = false

describe 'DublinCore Parser' do

  subject(:parser) { Libis::Tools::Metadata::DublinCoreParser.new }

  it 'parses simple DC' do
    expect {
      tree = parser.parse_with_debug('dc:title')
      # pp tree
      expect(tree).to be_a Hash
      expect(tree[:namespace]).to eq 'dc'
      expect(tree[:element]).to eq 'title'
      # noinspection RubyResolve
      expect(tree).not_to have_key :attributes
    }.not_to raise_error
  end

  it 'must see namespace' do
    expect {
      parser.parse('title')
    }.to raise_error(Parslet::ParseFailed)
  end

  it 'parses DC with attributes' do
    expect {
      tree = parser.parse_with_debug('dcterms:date xsi:type="http://example.com" foo:bar="baz"')
      # pp tree
      expect(tree).to be_a Hash
      expect(tree[:namespace]).to eq 'dcterms'
      expect(tree[:element]).to eq 'date'
      # noinspection RubyResolve
      expect(tree[:attributes].size).to be 2
      expect(tree[:attributes]).to eq [
                                          {namespace: 'xsi', name: 'type', value: 'http://example.com'},
                                          {namespace: 'foo', name: 'bar', value: 'baz'},
                                      ]
    }.not_to raise_error
  end

end