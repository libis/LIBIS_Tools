# encoding: utf-8
require_relative 'spec_helper'
require 'rspec/matchers'
require 'equivalent-xml'
require 'libis/tools/mets_file'
require 'libis/tools/xml_document'

describe 'METS File' do

  before(:all) do
    ::Libis::Tools::Config << {appname: 'LIBIS Default'}
  end

  subject(:mets_file) { ::Libis::Tools::MetsFile.new }

  context 'without data' do

    let(:skeleton) {
      ::Libis::Tools::XmlDocument.build do |xml|
        # noinspection RubyResolve
        xml[:mets].mets 'xmlns:mets' => 'http://www.loc.gov/METS/' do
          xml[:mets].amdSec 'ID' => 'ie-amd'
          xml[:mets].fileSec
        end
      end.document
    }

    it 'generates skeleton XML' do
      expect(mets_file.xml_doc.root).to be_equivalent_to skeleton.root
    end

  end

  context 'with IE AMD' do

    let(:dc_record) {
      record = Libis::Tools::Metadata::DublinCoreRecord.new
      record.title = 'Title'
      record.author = 'Author'
      record.subject = 'Subject'
      record
    }

    let(:marc_record) {
      Libis::Tools::XmlDocument.parse <<-STR
        <?xml version="1.0" encoding="UTF-8"?>
        <record xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
          xmlns="http://www.loc.gov/MARC21/slim" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          <leader>abcdefghiljklmnopqrstuvwxyz</leader>
          <controlfield tag="001">1234567890</controlfield>
          <datafield tag="010" ind1="a" ind2="b">
            <subfield code="a">abc</subfield>
            <subfield code="b">xyz</subfield>
          </datafield>
        </record>
        STR
    }

    let(:src_record) {
      Libis::Tools::XmlDocument.parse <<-STR
        <my_description xmlns="http://www.libis.be/description/">
          <title>Title</title>
          <importance>high</importance>
          <location>here</location>
        </my_description>
        STR
    }

    let(:target) {
      # noinspection RubyResolve
      ::Libis::Tools::XmlDocument.build do |xml|
        # noinspection RubyResolve
        xml[:mets].mets 'xmlns:mets' => 'http://www.loc.gov/METS/' do
          # noinspection RubyResolve
          xml[:mets].amdSec ID: 'ie-amd' do
            # noinspection RubyResolve
            xml[:mets].techMD ID: 'ie-amd-tech' do
              # noinspection RubyResolve
              xml[:mets].mdWrap MDTYPE: 'OTHER', OTHERMDTYPE: 'dnx' do
                # noinspection RubyResolve
                xml[:mets].xmlData do
                  xml.dnx xmlns: 'http://www.exlibrisgroup.com/dps/dnx' do
                    # noinspection RubyResolve
                    xml.section.objectCharacteristics! do
                      xml.record do
                        # noinspection RubyResolve
                        xml.key.groupID! 'group_id'
                      end
                    end
                    # noinspection RubyResolve
                    xml.section.generalIECharacteristics! do
                      # noinspection RubyResolve
                      xml.record do
                        xml.key.status! 'status'
                        xml.key.IEEntityType! 'entity_type'
                        xml.key.UserDefinedA! 'user_a'
                        xml.key.UserDefinedB! 'user_b'
                        xml.key.UserDefinedC! 'user_c'
                        xml.key.submissionReason! 'submission_reason'
                      end
                    end
                    # noinspection RubyResolve
                    xml.section.retentionPolicy! do
                      # noinspection RubyResolve
                      xml.record do
                        xml.key.policyId! 'retention_id'
                      end
                    end
                    # noinspection RubyResolve
                    xml.section.webHarvesting! do
                      # noinspection RubyResolve
                      xml.record do
                        xml.key.primarySeedURL! 'harvest_url'
                        xml.key.WCTIdentifier! 'harvest_id'
                        xml.key.targetName! 'harvest_target'
                        xml.key.group! 'harvest_group'
                        xml.key.harvestDate! 'harvest_date'
                        xml.key.harvestTime! 'harvest_time'
                      end
                    end
                  end
                end
              end
            end
            # noinspection RubyResolve
            xml[:mets].rightsMD ID: 'ie-amd-rights' do
              # noinspection RubyResolve
              xml[:mets].mdWrap MDTYPE: 'OTHER', OTHERMDTYPE: 'dnx' do
                # noinspection RubyResolve
                xml[:mets].xmlData do
                  xml.dnx xmlns: 'http://www.exlibrisgroup.com/dps/dnx' do
                    # noinspection RubyResolve
                    xml.section.accessRightsPolicy! do
                      # noinspection RubyResolve
                      xml.record do
                        xml.key.policyId! 'access_right'
                      end
                    end
                  end
                end
              end
            end
            # noinspection RubyResolve
            xml[:mets].sourceMD ID: 'ie-amd-source-DC-1' do
              # noinspection RubyResolve
              xml[:mets].mdWrap MDTYPE: 'DC' do
                # noinspection RubyResolve
                xml[:mets].xmlData do
                  # xml.parent.namespace = xml.parent.namespace_definitions.first
                  xml.parent << dc_record.root.to_xml
                end
              end
            end
            # noinspection RubyResolve
            xml[:mets].sourceMD ID: 'ie-amd-source-MARC-2' do
              # noinspection RubyResolve
              xml[:mets].mdWrap MDTYPE: 'MARC' do
                # noinspection RubyResolve
                xml[:mets].xmlData do
                  # xml.parent.namespace = xml.parent.namespace_definitions.first
                  xml.parent << marc_record.root.to_xml
                end
              end
            end
            # noinspection RubyResolve
            xml[:mets].sourceMD ID: 'ie-amd-source-OTHER-3' do
              # noinspection RubyResolve
              xml[:mets].mdWrap MDTYPE: 'OTHER' do
                # noinspection RubyResolve
                xml[:mets].xmlData do
                  # xml.namespace = xml.parent.namespace_definitions.first
                  xml.parent << src_record.root.to_xml
                end
              end
            end
          end
          xml[:mets].fileSec
        end
      end.document
    }

    it 'fills in IE-AMD section' do
      mets_file.amd_info = {
          group_id: 'group_id',
          status: 'status',
          entity_type: 'entity_type',
          user_a: 'user_a',
          user_b: 'user_b',
          user_c: 'user_c',
          submission_reason: 'submission_reason',
          retention_id: 'retention_id',
          harvest_url: 'harvest_url',
          harvest_id: 'harvest_id',
          harvest_target: 'harvest_target',
          harvest_group: 'harvest_group',
          harvest_date: 'harvest_date',
          harvest_time: 'harvest_time',
          access_right: 'access_right',
          source_metadata: [
              {
                  type: 'DC',
                  data: dc_record.root.to_xml
              }, {
                  type: 'Marc',
                  data: marc_record.root.to_xml
              }, {
                  type: 'other',
                  data: src_record.root.to_xml
              }
          ]
      }

      expect(mets_file.xml_doc.root).to be_equivalent_to target.root

    end
  end

end