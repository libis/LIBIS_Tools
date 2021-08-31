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
      Libis::Tools::XmlDocument.parse <<-STR
        <?xml version="1.0" encoding="UTF-8"?>
        <record xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcterms="http://purl.org/dc/terms/">
          <dc:title>Title</dc:title>
          <dc:author>Author</dc:author>
          <dc:subject>Subject</dc:subject>
        </record>
      STR
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

  context 'builder' do

    let(:dc_record) {
      Libis::Tools::XmlDocument.parse <<-STR
        <?xml version="1.0" encoding="UTF-8"?>
        <dc:record xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcterms="http://purl.org/dc/terms/">
          <dc:title>âbç d€f</dc:title>
        </dc:record>
      STR
    }

    let(:sample) {
      {
        dc_record: dc_record.root.to_xml,
        amd: {
          status: "ACTIVE",
          access_right: "AR_EVERYONE"
        },
        representations: [
          {
            preservation_type: "PRESERVATION_MASTER",
            usage_type: "VIEW",
            label: "Archiefkopie"
          },
        ],
        files: [
          {
            creation_date: '2021-08-27 14:14:26.367 UTC',
            modification_date: '2018-04-06 05:12:27.077 UTC',
            location: "/nas/upload/demo/test_diacritics/âbç d€f/aaa á aaa/b/abc.doc",
            target_location: "aaa á aaa/b/abc.doc",
            mimetype: "application/msword",
            size: 56320,
            puid: "fmt/39",
            checksum_MD5: "16ddbd5ad80411d8ac1b6acf8348adfb",
            label: "abc.doc",
            representation: 1,
          }, {
            creation_date: '2021-08-27 14:14:26.367 UTC',
            modification_date: '2018-04-06 05:13:04.635 UTC',
            location: "/nas/upload/demo/test_diacritics/âbç d€f/aaa á aaa/b/def.dóc",
            target_location: "aaa á aaa/b/def.dóc",
            mimetype: "application/msword",
            size: 45056,
            puid: "fmt/39",
            checksum_MD5: "b2907905a58f8599f07334cdc295c2f1",
            label: "def.dóc",
            representation: 1,
          }, {
            creation_date: '2021-08-27 14:14:26.366 UTC',
            modification_date: '2018-04-06 05:12:17.935 UTC',
            location: "/nas/upload/demo/test_diacritics/âbç d€f/aaa á aaa/b/ábc.doc",
            target_location: "aaa á aaa/b/ábc.doc",
            mimetype: "application/msword",
            size: 61440,
            puid: "fmt/39",
            checksum_MD5: "312bba1438acdb17e3d69d19fe4cac4b",
            label: "ábc.doc",
            representation: 1,
          }, {
            creation_date: '2021-08-27 14:14:26.346 UTC',
            modification_date: '2018-04-06 05:06:40.297 UTC',
            location: "/nas/upload/demo/test_diacritics/âbç d€f/aaa á aaa/ccçcc/ã b ç d ë ¼.doc",
            target_location: "aaa á aaa/ccçcc/ã b ç d ë ¼.doc",
            mimetype: "application/msword",
            size: 50688,
            puid: "fmt/39",
            checksum_MD5: "cd3e8cfa9cf5ada3485e205d706cee09",
            label: "ã b ç d ë ¼.doc",
            representation: 1,
          }, {
            creation_date: '2021-08-27 14:14:26.356 UTC',
            modification_date: '2018-04-06 05:11:07.095 UTC',
            location: "/nas/upload/demo/test_diacritics/âbç d€f/aaa á aaa/ss$ss/ã b ç d ë ¼.doc",
            target_location: "aaa á aaa/ss$ss/ã b ç d ë ¼.doc",
            mimetype: "application/msword",
            size: 61440,
            puid: "fmt/39",
            checksum_MD5: "312bba1438acdb17e3d69d19fe4cac4b",
            label: "ã b ç d ë ¼.doc",
            representation: 1,
          },
        ],
        divs: [
          {
            label: "âbç d€f"
          }, {
            parent: 1,
            label: "aaa á aaa",
          }, {
            parent: 2,
            label: "b",
            files: [1,2,3]
          }, {
            parent: 2,
            label: "ccçcc",
            files: [4]
          }, {
            parent: 2,
            label: "ss$ss",
            files: [5]
          },
        ],
        maps: [
          {
            representation: 1,
            div: 1,
            is_logical: false
          }
        ]
      }
    }

    let(:target) {
      ::Libis::Tools::XmlDocument.build do |xml|
        xml[:mets].mets 'xmlns:mets' => 'http://www.loc.gov/METS/' do
          xml[:mets].dmdSec ID: 'ie-dmd' do
            xml[:mets].mdWrap MDTYPE: 'DC' do
              xml[:mets].xmlData do
                xml << dc_record.root.to_xml
                # xml[:dc].record(
                #   'xmlns:dc' => 'http://purl.org/dc/elements/1.1/',
                #   'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                #   'xmlns:dcterms' => 'http://purl.org/dc/terms/'
                # ) do
                #   xml[:dc].title 'âbç d€f'
                # end
              end
            end
          end
          xml[:mets].amdSec ID: 'ie-amd' do
            xml[:mets].techMD ID: 'ie-amd-tech' do
              xml[:mets].mdWrap MDTYPE: 'OTHER', OTHERMDTYPE: 'dnx' do
                xml[:mets].xmlData do
                  xml.dnx xmlns: 'http://www.exlibrisgroup.com/dps/dnx' do
                    xml.section.generalIECharacteristics! do
                      xml.record do
                        xml.key.status! 'ACTIVE'
                      end
                    end
                  end
                end
              end
            end
            xml[:mets].rightsMD ID: 'ie-amd-rights' do
              xml[:mets].mdWrap MDTYPE: 'OTHER', OTHERMDTYPE: 'dnx' do
                xml[:mets].xmlData do
                  xml.dnx xmlns: 'http://www.exlibrisgroup.com/dps/dnx' do
                    xml.section.accessRightsPolicy! do
                      xml.record do
                        xml.key.policyId! 'AR_EVERYONE'
                      end
                    end
                  end
                end
              end
            end
          end
          xml[:mets].amdSec ID: 'rep1-amd' do
            xml[:mets].techMD ID: 'rep1-amd-tech' do
              xml[:mets].mdWrap MDTYPE: 'OTHER', OTHERMDTYPE: 'dnx' do
                xml[:mets].xmlData do
                  xml.dnx xmlns: 'http://www.exlibrisgroup.com/dps/dnx' do
                    xml.section.generalRepCharacteristics! do
                      xml.record do
                        xml.key.preservationType! 'PRESERVATION_MASTER'
                        xml.key.usageType! 'VIEW'
                        xml.key.label! 'Archiefkopie'
                      end
                    end
                  end
                end
              end
            end
          end
          xml[:mets].amdSec ID: 'fid1-amd' do
            xml[:mets].techMD ID: 'fid1-amd-tech' do
              xml[:mets].mdWrap MDTYPE: 'OTHER', OTHERMDTYPE: 'dnx' do
                xml[:mets].xmlData do
                  xml.dnx xmlns: 'http://www.exlibrisgroup.com/dps/dnx' do
                    xml.section.generalFileCharacteristics! do
                      xml.record do
                        xml.key.label! 'abc.doc'
                        xml.key.fileCreationDate! '2021-08-27 14:14:26.367 UTC'
                        xml.key.fileModificationDate! '2018-04-06 05:12:27.077 UTC'
                        xml.key.fileLocation! '/nas/upload/demo/test_diacritics/âbç d€f/aaa á aaa/b/abc.doc'
                        xml.key.fileOriginalName! 'abc.doc'
                        xml.key.fileOriginalPath! 'aaa á aaa/b'
                        xml.key.fileMIMEType! 'application/msword'
                        xml.key.fileSizeBytes! '56320'
                      end
                    end
                    xml.section.fileFixity! do
                      xml.record do
                        xml.key.fixityType! 'MD5'
                        xml.key.fixityValue! '16ddbd5ad80411d8ac1b6acf8348adfb'
                      end
                    end
                    xml.section.objectCharacteristics! do
                      xml.record do
                        xml.key.groupID! 'grp'
                      end
                    end
                  end
                end
              end
            end
          end
          xml[:mets].amdSec ID: 'fid2-amd' do
            xml[:mets].techMD ID: 'fid2-amd-tech' do
              xml[:mets].mdWrap MDTYPE: 'OTHER', OTHERMDTYPE: 'dnx' do
                xml[:mets].xmlData do
                  xml.dnx xmlns: 'http://www.exlibrisgroup.com/dps/dnx' do
                    xml.section.generalFileCharacteristics! do
                      xml.record do
                        xml.key.label! 'def.dóc'
                        xml.key.fileCreationDate! '2021-08-27 14:14:26.367 UTC'
                        xml.key.fileModificationDate! '2018-04-06 05:13:04.635 UTC'
                        xml.key.fileLocation! '/nas/upload/demo/test_diacritics/âbç d€f/aaa á aaa/b/def.dóc'
                        xml.key.fileOriginalName! 'def.dóc'
                        xml.key.fileOriginalPath! 'aaa á aaa/b'
                        xml.key.fileMIMEType! 'application/msword'
                        xml.key.fileSizeBytes! '45056'
                      end
                    end
                    xml.section.fileFixity! do
                      xml.record do
                        xml.key.fixityType! 'MD5'
                        xml.key.fixityValue! 'b2907905a58f8599f07334cdc295c2f1'
                      end
                    end
                    xml.section.objectCharacteristics! do
                      xml.record do
                        xml.key.groupID! 'grp'
                      end
                    end
                  end
                end
              end
            end
          end
          xml[:mets].amdSec ID: 'fid3-amd' do
            xml[:mets].techMD ID: 'fid3-amd-tech' do
              xml[:mets].mdWrap MDTYPE: 'OTHER', OTHERMDTYPE: 'dnx' do
                xml[:mets].xmlData do
                  xml.dnx xmlns: 'http://www.exlibrisgroup.com/dps/dnx' do
                    xml.section.generalFileCharacteristics! do
                      xml.record do
                        xml.key.label! 'ábc.doc'
                        xml.key.fileCreationDate! '2021-08-27 14:14:26.366 UTC'
                        xml.key.fileModificationDate! '2018-04-06 05:12:17.935 UTC'
                        xml.key.fileLocation! '/nas/upload/demo/test_diacritics/âbç d€f/aaa á aaa/b/ábc.doc'
                        xml.key.fileOriginalName! 'ábc.doc'
                        xml.key.fileOriginalPath! 'aaa á aaa/b'
                        xml.key.fileMIMEType! 'application/msword'
                        xml.key.fileSizeBytes! '61440'
                      end
                    end
                    xml.section.fileFixity! do
                      xml.record do
                        xml.key.fixityType! 'MD5'
                        xml.key.fixityValue! '312bba1438acdb17e3d69d19fe4cac4b'
                      end
                    end
                    xml.section.objectCharacteristics! do
                      xml.record do
                        xml.key.groupID! 'grp'
                      end
                    end
                  end
                end
              end
            end
          end
          xml[:mets].amdSec ID: 'fid4-amd' do
            xml[:mets].techMD ID: 'fid4-amd-tech' do
              xml[:mets].mdWrap MDTYPE: 'OTHER', OTHERMDTYPE: 'dnx' do
                xml[:mets].xmlData do
                  xml.dnx xmlns: 'http://www.exlibrisgroup.com/dps/dnx' do
                    xml.section.generalFileCharacteristics! do
                      xml.record do
                        xml.key.label! 'ã b ç d ë ¼.doc'
                        xml.key.fileCreationDate! '2021-08-27 14:14:26.346 UTC'
                        xml.key.fileModificationDate! '2018-04-06 05:06:40.297 UTC'
                        xml.key.fileLocation! '/nas/upload/demo/test_diacritics/âbç d€f/aaa á aaa/ccçcc/ã b ç d ë ¼.doc'
                        xml.key.fileOriginalName! 'ã b ç d ë ¼.doc'
                        xml.key.fileOriginalPath! 'aaa á aaa/ccçcc'
                        xml.key.fileMIMEType! 'application/msword'
                        xml.key.fileSizeBytes! '50688'
                      end
                    end
                     xml.section.fileFixity! do
                      xml.record do
                        xml.key.fixityType! 'MD5'
                        xml.key.fixityValue! 'cd3e8cfa9cf5ada3485e205d706cee09'
                      end
                    end
                    xml.section.objectCharacteristics! do
                      xml.record do
                        xml.key.groupID! 'grp'
                      end
                    end
                  end
                end
              end
            end
          end
          xml[:mets].amdSec ID: 'fid5-amd' do
            xml[:mets].techMD ID: 'fid5-amd-tech' do
              xml[:mets].mdWrap MDTYPE: 'OTHER', OTHERMDTYPE: 'dnx' do
                xml[:mets].xmlData do
                  xml.dnx xmlns: 'http://www.exlibrisgroup.com/dps/dnx' do
                    xml.section.generalFileCharacteristics! do
                      xml.record do
                        xml.key.label! 'ã b ç d ë ¼.doc'
                        xml.key.fileCreationDate! '2021-08-27 14:14:26.356 UTC'
                        xml.key.fileModificationDate! '2018-04-06 05:11:07.095 UTC'
                        xml.key.fileLocation! '/nas/upload/demo/test_diacritics/âbç d€f/aaa á aaa/ss$ss/ã b ç d ë ¼.doc'
                        xml.key.fileOriginalName! 'ã b ç d ë ¼.doc'
                        xml.key.fileOriginalPath! 'aaa á aaa/ss$ss'
                        xml.key.fileMIMEType! 'application/msword'
                        xml.key.fileSizeBytes! '61440'
                      end
                    end
                     xml.section.fileFixity! do
                      xml.record do
                        xml.key.fixityType! 'MD5'
                        xml.key.fixityValue! '312bba1438acdb17e3d69d19fe4cac4b'
                      end
                    end
                    xml.section.objectCharacteristics! do
                      xml.record do
                        xml.key.groupID! 'grp'
                      end
                    end
                  end
                end
              end
            end
          end
          xml[:mets].fileSec do
            xml[:mets].fileGrp ID: 'rep1', USE: 'VIEW', ADMID: 'rep1-amd' do
              xml[:mets].file ID: 'fid1', MIMETYPE: 'application/msword', ADMID: 'fid1-amd', GROUPID: 'grp' do
                xml[:mets].FLocat 'xmlns:xlin' => 'http://www.w3.org/1999/xlink', LOCTYPE: 'URL', 'xlin:href' => 'aaa á aaa/b/abc.doc'
              end
              xml[:mets].file ID: 'fid2', MIMETYPE: 'application/msword', ADMID: 'fid2-amd', GROUPID: 'grp' do
                xml[:mets].FLocat 'xmlns:xlin' => 'http://www.w3.org/1999/xlink', LOCTYPE: 'URL', 'xlin:href' => 'aaa á aaa/b/def.dóc'
              end
              xml[:mets].file ID: 'fid3', MIMETYPE: 'application/msword', ADMID: 'fid3-amd', GROUPID: 'grp' do
                xml[:mets].FLocat 'xmlns:xlin' => 'http://www.w3.org/1999/xlink', LOCTYPE: 'URL', 'xlin:href' => 'aaa á aaa/b/ábc.doc'
              end
              xml[:mets].file ID: 'fid4', MIMETYPE: 'application/msword', ADMID: 'fid4-amd', GROUPID: 'grp' do
                xml[:mets].FLocat 'xmlns:xlin' => 'http://www.w3.org/1999/xlink', LOCTYPE: 'URL', 'xlin:href' => 'aaa á aaa/ccçcc/ã b ç d ë ¼.doc'
              end
              xml[:mets].file ID: 'fid5', MIMETYPE: 'application/msword', ADMID: 'fid5-amd', GROUPID: 'grp' do
                xml[:mets].FLocat 'xmlns:xlin' => 'http://www.w3.org/1999/xlink', LOCTYPE: 'URL', 'xlin:href' => 'aaa á aaa/ss$ss/ã b ç d ë ¼.doc'
              end
            end
          end
          xml[:mets].structMap ID: 'rep1-1', TYPE: 'PHYSICAL' do
            xml[:mets].div LABEL: 'Archiefkopie' do
              xml[:mets].div LABEL: 'âbç d€f' do
                xml[:mets].div LABEL: 'aaa á aaa' do
                  xml[:mets].div LABEL: 'b' do
                    xml[:mets].div LABEL: 'abc.doc', TYPE: 'FILE' do
                      xml[:mets].fptr FILEID: 'fid1'
                    end
                    xml[:mets].div LABEL: 'def.dóc', TYPE: 'FILE' do
                      xml[:mets].fptr FILEID: 'fid2'
                    end
                    xml[:mets].div LABEL: 'ábc.doc', TYPE: 'FILE' do
                      xml[:mets].fptr FILEID: 'fid3'
                    end
                  end
                  xml[:mets].div LABEL: 'ccçcc' do
                    xml[:mets].div LABEL: 'ã b ç d ë ¼.doc', TYPE: 'FILE' do
                      xml[:mets].fptr FILEID: 'fid4'
                    end
                  end
                  xml[:mets].div LABEL: 'ss$ss' do
                    xml[:mets].div LABEL: 'ã b ç d ë ¼.doc', TYPE: 'FILE' do
                      xml[:mets].fptr FILEID: 'fid5'
                    end
                  end
                end
              end
            end
          end
        end
      end.document
    }

    it 'produces METS XML' do
      mets_file.dc_record = sample[:dc_record]
      mets_file.amd_info = sample[:amd]
      sample[:representations].each do |rep|
        mets_file.representation(rep)
      end
      sample[:files].each do |file|
        rep_id = file.delete(:representation)
        rep = mets_file.representations[rep_id]
        mets_file.file(file).representation = rep
      end
      sample[:divs].each do |div|
        parent = div.delete(:parent)
        files = div.delete(:files)
        d = mets_file.div(div)
        files.each { |f| d << mets_file.files[f] } if files
        mets_file.divs[parent] << d if parent
      end
      sample[:maps].each do |map|
        rep = mets_file.representations[map[:representation]]
        div = mets_file.divs[map[:div]]
        mets_file.map(rep, div)
      end

      expect(mets_file.xml_doc.root).to be_equivalent_to target.root
    end
  end

end