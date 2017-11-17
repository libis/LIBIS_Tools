# encoding: utf-8
require_relative '../spec_helper'
require 'libis/tools/metadata/marc21_record'
require 'libis/tools/xml_document'

require 'rspec/matchers'
require 'equivalent-xml'
require 'libis/tools/extend/string'

describe 'Marc21Record' do

  subject(:record) { Libis::Tools::Metadata::Marc21Record.new(data) {} }
  let(:data) { xml.root }

  context '8389207' do
    let(:xml) { Libis::Tools::XmlDocument.open(File.join(File.dirname(__FILE__), '8389207.marc')) }

    it 'load from xml' do
      expect(record.marc_dump).to eq <<-STR.align_left
        LDR:'01068nam 2200241u 4500'
        005:'20150701153710.0'
        008:'000608m17221724xx |||| |     000|0 lat c'
        001:'9921543960101471'
        035: : :
        \ta:["(BeLVLBS)002154396LBS01-Aleph"]
        035: : :
        \ta:["8389207"]
        245:0:0:
        \ta:["Anecdota Graeca, sacra et profana /"]
        \tc:["ex codicibus manu exaratis nunc primum in lucem edita, versione Latina donata, et notis\\n      illustrata a Io. Christophoro Wolfio ... Tom. I [-IIII]\\n    "]
        264: :1:
        \ta:["Hamburgi"]
        \tb:["apud Theodorum Christophorum Felginer,"]
        \tc:["1722-1724"]
        300: : :
        \ta:["8o: 4 v.; [22], 298, [8]; [16], 354, [1]; [16], 299, [7]; [16], 271, [5] p."]
        336: : :
        \ta:["text"]
        \t2:["rdacontent"]
        337: : :
        \ta:["unmediated"]
        \t2:["rdamedia"]
        338: : :
        \ta:["volume"]
        \t2:["rdacarrier"]
        500: : :
        \ta:["Ded. Petrus Theodorus Seelmann; Erdmannus Neumeister; Thomas Claussen; Joannes Grammius\\n    "]
        500: : :
        \ta:["Elk deel heeft eigen titelp. in roodzwartdruk, met drukkersmerk"]
        650: :7:
        \t2:["UDC"]
        \ta:["276 =75"]
        \tx:["Griekse patrologie"]
        650: :7:
        \t2:["KADOC"]
        \ta:["Bisdom Antwerpen (1961-heden)"]
        \t6:["(ODIS-ORG)9284"]
        650: :7:
        \t2:["KADOC"]
        \ta:["Studiecentrum voor Zielzorg en Predicatie"]
        \t6:["(ODIS-ORG)24894"]
        650: :7:
        \t2:["KADOC"]
        \ta:["Antwerpen [deelgemeente in gemeente Antwerpen - BE]"]
        \t6:["(ODIS-GEO)10560000006504"]
        650: :7:
        \t2:["KADOC"]
        \ta:["C1"]
        \tx:["Kerken en religie"]
        \t6:["(ODIS-HT)"]
        653: :6:
        \ta:["Books before 1840"]
        700:1: :
        \ta:["Wolf, Johann Christoph"]
        \td:["1683-1739"]
        \t4:["aut"]
        953: : :
        \ta:["1701-1750"]
        998: : :
        \ta:["LBS01"]
        \tb:["bib_200501.mrc.2.av"]
        INST: : :
        \ta:["32KUL_LIBIS_NETWORK"]
        \tb:["P"]
        \tc:["71134440820001471"]
        INST: : :
        \ta:["32KUL_KUL"]
        \tb:["P"]
        \tc:["21304345390001488"]
        AVA: : :
        \ta:["32KUL_KUL"]
        \tb:["GBIB"]
        \tc:["GBIB: Godgeleerdheid"]
        \td:["276.030.4 WOLF Anec"]
        \te:["available"]
        \tf:["1"]
        \tg:["0"]
        \tj:["GBIB"]
        \tp:["1"]
        MMS: : :
        \tb:["9921543960101471"]
        \ta:["32KUL_LIBIS_NETWORK"]
        MMS: : :
        \tb:["9921543960101488"]
        \ta:["32KUL_KUL"]
      STR
    end

    it 'convert to dublin core' do
      record.extend Libis::Tools::Metadata::Mappers::Kuleuven
      xml_doc = Libis::Tools::XmlDocument.parse <<STR
<?xml version="1.0" encoding="utf-8"?>
<dc:record xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/">
  <dc:identifier>urn:ControlNumber:9921543960101471</dc:identifier>
  <dc:identifier>(BeLVLBS)002154396LBS01-Aleph</dc:identifier>
  <dc:identifier>8389207</dc:identifier>
  <dc:title>Anecdota Graeca, sacra et profana /</dc:title>
  <dc:creator>Wolf, Johann Christoph, 1683-1739, (author)</dc:creator>
  <dc:subject xsi:type="http://purl.org/dc/terms/UDC">276 =75 Griekse patrologie</dc:subject>
  <dc:subject xsi:type="dcterms:URI">http://www.odis.be/lnk/or_9284#Bisdom+Antwerpen+%281961-heden%29</dc:subject>
  <dc:subject xsi:type="dcterms:URI">http://www.odis.be/lnk/or_24894#Studiecentrum+voor+Zielzorg+en+Predicatie</dc:subject>
  <dc:temporal>1701-1750</dc:temporal>
  <dc:description>Ded. Petrus Theodorus Seelmann; Erdmannus Neumeister; Thomas Claussen; Joannes Grammius\n    \nElk deel heeft eigen titelp. in roodzwartdruk, met drukkersmerk</dc:description>
  <dc:date>1722 - 1724</dc:date>
  <dc:type xml:lang="en">Books before 1840</dc:type>
  <dcterms:extent>8o: 4 v.; [22], 298, [8]; [16], 354, [1]; [16], 299, [7]; [16], 271, [5] p.</dcterms:extent>
  <dc:language>la</dc:language>
  <dc:coverage>Antwerpen [deelgemeente in gemeente Antwerpen - BE] [(ODIS-GEO)10560000006504]</dc:coverage>
</dc:record>
STR
      record.to_dc.root.elements.each_with_index do |element, i|
        expect(element).to be_equivalent_to(xml_doc.root.elements[i])
      end
    end
  end

  context '123456789' do
    let(:xml) { Libis::Tools::XmlDocument.open(File.join(File.dirname(__FILE__), '123456789.marc')) }

    it 'load from xml' do
      # puts record.marc_dump
      expect(record.marc_dump).to eq <<-STR.align_left
        LDR:'01068nam 2200241u 4500'
        005:'20150701153710.0'
        008:'000608m17221724xx |||| |     000|0 lat c'
        001:'9901234567890471'
        035: : :
        \ta:["(BeLVLBS)123456789LBS01-Aleph"]
        035: : :
        \ta:["123456789"]
        245:0:0:
        \ta:["Title with special chars: 'éÄçñåúðäíö' / \\\"ß¥²¤€®©œøæ’×½¼þ«»¶ǽµ¢ŒÆØŒ§Ð\\\" < & % $ # >"]
        \tc:["subtitle with special chars: \\\"ß¥²¤€®©œøæ’×½¼þ«»¶ǽµ¢ŒÆØŒ§Ð\\\" < & % $ # >"]
      STR
    end

    it 'convert to dublin core' do
      record.extend Libis::Tools::Metadata::Mappers::Kuleuven
      xml_doc = Libis::Tools::XmlDocument.parse <<STR
<?xml version="1.0" encoding="utf-8"?>
<dc:record xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/">
  <dc:identifier>urn:ControlNumber:9901234567890471</dc:identifier>
  <dc:identifier>(BeLVLBS)123456789LBS01-Aleph</dc:identifier>
  <dc:identifier>123456789</dc:identifier>
  <dc:title>Title with special chars: &apos;éÄçñåúðäíö&apos; / &quot;ß¥²¤€®©œøæ’×½¼þ«»¶ǽµ¢ŒÆØŒ§Ð&quot; &lt; &amp; % $ # &gt;</dc:title>
  <dc:date>1722 - 1724</dc:date>
  <dc:language>la</dc:language>
</dc:record>
STR
      # puts puts record.to_dc.to_xml
      record.to_dc.root.elements.each_with_index do |element, i|
        expect(element).to be_equivalent_to(xml_doc.root.elements[i])
      end
    end
  end

end

