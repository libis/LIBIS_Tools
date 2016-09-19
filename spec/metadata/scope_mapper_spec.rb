require_relative '../spec_helper'
require 'libis/tools'

require 'rspec/matchers'
require 'equivalent-xml'

describe 'ScopeMapper' do

  let(:input) { File.join(File.dirname(__FILE__), 'BE_942855_1927_4898_md.XML')}
  let(:output) { File.join(File.dirname(__FILE__), 'BE_942855_1927_4898_corrected.XML')}

  it 'Correct Scope output' do

    input_dc = Libis::Tools::Metadata::DublinCoreRecord.new(input)
    expect(input_dc).to be_a Libis::Tools::Metadata::DublinCoreRecord

    output_dc = Libis::Tools::Metadata::DublinCoreRecord.new(output)
    expect(output_dc).to be_a Libis::Tools::Metadata::DublinCoreRecord

    input_dc.extend Libis::Tools::Metadata::Mappers::Scope
    converted_dc = input_dc.to_dc
    expect(converted_dc).to be_a Libis::Tools::Metadata::DublinCoreRecord

    converted_dc.root.elements.each_with_index do |element, i|
      expect(element).to be_equivalent_to(output_dc.root.elements[i])
    end

  end
end