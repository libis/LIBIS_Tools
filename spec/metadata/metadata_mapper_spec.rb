# encoding: utf-8
require_relative '../spec_helper'
require 'libis/tools/metadata/mapper'
require 'libis/tools/metadata/parsers'
require 'parslet'
require 'parslet/convenience'
require 'pp'

$DEBUG = false

describe 'Metadata Mapper' do

  subject(:mapper) { Libis::Tools::Metadata::Mapper.new(
      Libis::Tools::Metadata::Marc21Parser.new,
      Libis::Tools::Metadata::DublinCoreParser.new,
      Libis::Tools::Metadata::Marc21Parser.new,
      File.join(File.dirname(__FILE__), '..', 'data', 'MetadataMapping.xlsx')) }

  it 'Initialization' do
    expect(mapper).to_not be_nil
  end

end