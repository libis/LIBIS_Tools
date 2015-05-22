# encoding: utf-8
require_relative '../spec_helper'
require 'libis/tools/metadata/dublin_core_record'

describe 'DublinCoreRecord' do

  let(:header) { ['<?xml version="1.0" encoding="utf-8"?>'] }

  subject(:dc) { Libis::Tools::Metadata::DublinCoreRecord.new(data) {} }

  def dc_xml(tag, value = '', attributes = {})
    "<dc:#{tag}#{attributes.sort.each{|k,v| " #{k}=\"#{v}\""}.join}>#{value}</dc:#{tag}>"
  end

  def dcterms_xml(tag, value = '', attributes = {})
    "<dcterms:#{tag}#{attributes.sort.each{|k,v| " #{k}=\"#{v}\""}.join}>#{value}</dcterms:#{tag}>"
  end

  def cmp_text(txt, other)
    other_array = (other.is_a?(Array) ? other : other.split("\n"))
    txt_array = txt.split("\n")
    expect(txt_array.size).to be other_array.size
    txt_array.each_with_index do |t, i|
      expect(t).to match Regexp.new(Regexp.escape(other_array[i]), Regexp::EXTENDED)
    end
  end

  context 'Empty record' do
    let(:data) { nil }
    let(:root) { <<STR.chomp
<record \
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" \
xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/"
STR
    }
    let(:record_start) { root + '>' }
    let(:record_end) { '</record>' }
    let(:empty_record) { header.dup << (root + '/>') }


    it 'contains emtpy record' do
      cmp_text(dc.to_xml, empty_record)
    end

    it 'add dc:title' do
      dc.title = 'abc'
      xml = header.dup
      xml << record_start << dc_xml('title', 'abc') << record_end
      cmp_text(dc.to_xml, xml )
    end

    it 'add dc:date' do
      dc.date = '2001'
      dc.dcdate = '2002'
      dc.dc_date = '2003'
      xml = header.dup
      xml << record_start <<
          dc_xml('date', '2001') <<
          dc_xml('date', '2002') <<
          dc_xml('date', '2003') <<
          record_end
      cmp_text(dc.to_xml, xml )
    end

    it 'add dcterms:date' do
      dc.termsdate = '2001'
      dc.dctermsdate = '2002'
      dc.terms_date = '2003'
      dc.dcterms_date = '2004'
      xml = header.dup
      xml << record_start <<
          dcterms_xml('date', '2001') <<
          dcterms_xml('date', '2002') <<
          dcterms_xml('date', '2003') <<
          dcterms_xml('date', '2004') <<
          record_end
      cmp_text(dc.to_xml, xml )
    end

  end

end