# encoding: utf-8
require_relative '../spec_helper'
require 'libis/tools/metadata/dublin_core_record'

require 'rspec/matchers'
require 'equivalent-xml'

describe 'DublinCoreRecord' do

  let(:header) { '<?xml version="1.0" encoding="utf-8"?>' }

  subject(:dc) { Libis::Tools::Metadata::DublinCoreRecord.new(data) {} }

  def dc_xml(tag, value = '', attributes = {})
    "<dc:#{tag}#{attributes.sort.each{|k,v| " #{k}=\"#{v}\""}.join}>#{value}</dc:#{tag}>"
  end

  def dcterms_xml(tag, value = '', attributes = {})
    "<dcterms:#{tag}#{attributes.sort.each{|k,v| " #{k}=\"#{v}\""}.join}>#{value}</dcterms:#{tag}>"
  end

  def match_xml(doc1, doc2)
    xml1 = doc1.is_a?(::Libis::Tools::XmlDocument) ? doc1.document : ::Nokogiri::XML(doc1.to_s)
    xml2 = doc2.is_a?(::Libis::Tools::XmlDocument) ? doc2.document : ::Nokogiri::XML(doc2.to_s)
    # noinspection RubyResolve
    expect(xml1).to be_equivalent_to(xml2).respecting_element_order
  end

  context 'Empty record' do
    let(:data) { nil }
    let(:root) { <<STR.chomp
<dc:record \
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" \
xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/"
STR
    }
    let(:record_start) { root + '>' }
    let(:record_end) { '</dc:record>' }
    let(:empty_record) { header + root + '/>' }


    it 'contains emtpy record' do
      match_xml dc.document, empty_record
    end

    it 'add dc:title' do
      dc.title = 'abc'
      match_xml dc.document, header + record_start + dc_xml('title', 'abc') + record_end
    end

    it 'add dc:date' do
      dc.date = '2001'
      dc.dcdate = '2002'
      dc.dc_date = '2003'
      match_xml dc.document,
                header +
                    record_start +
                    dc_xml('date', '2001') +
                    dc_xml('date', '2002') +
                    dc_xml('date', '2003') +
                    record_end
    end

    it 'add dcterms:date' do
      dc.termsdate = '2001'
      dc.dctermsdate = '2002'
      dc.terms_date = '2003'
      dc.dcterms_date = '2004'
      match_xml dc.document,
                header +
                    record_start +
                    dcterms_xml('date', '2001') +
                    dcterms_xml('date', '2002') +
                    dcterms_xml('date', '2003') +
                    dcterms_xml('date', '2004') +
                    record_end
    end

  end

end