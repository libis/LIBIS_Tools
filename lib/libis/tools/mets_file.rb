# encoding: utf-8
require 'ostruct'

require 'libis/tools/extend/hash'
require_relative 'xml_document'

module LIBIS
  module Tools

    # noinspection RubyResolve
    # noinspection RubyClassVariableUsageInspection
    class MetsFile

      module IdContainer

        def set_from_hash(h)
          h.each { |k, v| send "#{k}=", v }
        end

        def id
          return @id if @id
          @id = self.class.instance_variable_get('@id') || 1
          self.class.instance_variable_set('@id', @id + 1)
          @id
        end

        def to_s
          "#{self.class}:\n" +
              self.instance_variables.map do |var|
                v = self.instance_variable_get(var)
                v = "#{v.class}-#{v.id}" if v.is_a? IdContainer
                v = v.map do |x|
                  x.is_a?(IdContainer) ? "#{x.class}-#{x.id}" : x.to_s
                end.join(',') if v.is_a? Array
                " - #{var.to_s.gsub(/^@/, '')}: #{v}"
              end.join("\n")
        end

      end

      class Representation
        include IdContainer

        attr_accessor :label, :preservation_type, :usage_type, :dc_record

        def xml_id
          "rep#{id}"
        end

        def amd
          dnx = {}
          tech_data = []
          data = {
              preservationType: preservation_type,
              usageType: usage_type,
              # RevisionNumber: 1,
              # DigitalOriginal: true,
          }.cleanup
          tech_data << TechGeneralRep.new(data) unless data.empty?
          dnx[:tech] = tech_data unless tech_data.empty?
          dnx
        end

      end

      class File
        include IdContainer

        attr_accessor :label, :location, :target_location, :mimetype, :entity_type, :representation, :dc_record

        def xml_id
          "fid#{id}"
        end

        def group_id
          "grp#{master.id rescue id}"
        end

        def master
          @master ||= nil
        end

        def master=(file)
          @master = file
        end

        def manifestations
          @manifestations ||= Array.new
        end

        def add_manifestation(file)
          manifestations << file
          file.master = self
        end

        def orig_name
          ::File.basename(location)
        end

        def orig_path
          ::File.dirname(location)
        end

        def target
          if target_location.nil?
            return "#{xml_id}#{::File.extname(location)}"
          end
          target_location
        end

        def amd
          dnx = {}
          tech_data = []
          data = {
              label: label,
              fileMIMEType: mimetype,
              fileOriginalName: orig_name,
              fileOriginalPath: orig_path,
              FileEntityType: entity_type,
              # fileSizeBytes: size,
          }.cleanup
          tech_data << TechGeneralFile.new(data) unless data.empty?
          # data = {
          #     fixityType: fixity_type,
          #     fixityValue: fixity_value,
          # }.cleanup
          # tech_data << TechFixity.new(data) unless data.empty?
          dnx[:tech] = tech_data unless tech_data.empty?
          dnx
        end

      end

      class Div
        include IdContainer

        attr_accessor :label

        def xml_id
          "div-#{id}"
        end

        def children
          files + divs
        end

        def files
          @files ||= Array.new
        end

        def divs
          @divs ||= Array.new
        end

        def <<(obj)
          case obj
            when File
              files << obj
            when Div
              divs << obj
            else
              raise RuntimeError, "Child object type not supported: #{obj.class}"
          end
        end
      end

      class Map
        include IdContainer

        attr_accessor :representation, :div

        def xml_id
          "smap-#{id}"
        end

      end

      class DnxSection < OpenStruct
        def self.tag(value = nil)
          var_name = '@tag'
          if value.nil?
            instance_variable_get(var_name)
          else
            instance_variable_set(var_name, value)
          end
        end

        def tag
          self.class.tag
        end
      end

      class TechGeneralIE < DnxSection
        tag 'generalIECharacteristics'
      end

      class TechGeneralRep < DnxSection
        tag 'generalRepCharacteristics'
      end

      class TechGeneralFile < DnxSection
        tag 'generalFileCharacteristics'
      end

      class RetentionPeriod < DnxSection
        tag 'retentionPolicy'
      end

      class TechFixity < DnxSection
        tag 'fileFixity'
      end

      class Rights < DnxSection
        tag 'accessRightsPolicy'
      end

      attr_reader :representations, :files, :divs, :maps

      # noinspection RubyConstantNamingConvention
      NS = {
          mets: 'http://www.loc.gov/METS/',
          dc: 'http://purl.org/dc/elements/1.1/',
          dnx: 'http://www.exlibrisgroup.com/dps/dnx',
          xlin: 'http://www.w3.org/1999/xlink',
      }

      def initialize
        @representations = {}
        @files = {}
        @divs = {}
        @maps = {}
      end

      def self.parse(xml)
        xml_doc = case xml
                    when String
                      LIBIS::Tools::XmlDocument.parse(xml).document
                    when Hash
                      LIBIS::Tools::XmlDocument.from_hash(xml).document
                    when LIBIS::Tools::XmlDocument
                      xml.document
                    when Nokogiri::XML::Document
                      xml
                    else
                      raise ArgumentError, "LIBIS::Tools::MetsFile#parse does not accept input of type #{xml.class}"
                  end

        dmd_sec = xml_doc.root.xpath('mets:dmdSec', NS).inject({}) do |hash_dmd, dmd|
          hash_dmd[dmd[:ID]] = dmd.xpath('.//dc:record', NS).first.children.inject({}) do |h, c|
            h[c.name] = c.content
            h
          end
          hash_dmd
        end
        amd_sec = xml_doc.root.xpath('mets:amdSec', NS).inject({}) do |hash_amd, amd|
          hash_amd[amd[:ID]] = [:tech, :rights, :source, :digiprov].inject({}) do |hash_sec, sec|
            md = amd.xpath("mets:#{sec}MD", NS).first
            return hash_sec unless md
            # hash_sec[sec] = md.xpath('mets:mdWrap/dnx:dnx/dnx:section', NS).inject({}) do |hash_md, dnx_sec|
            hash_sec[sec] = md.xpath('.//dnx:section', NS).inject({}) do |hash_md, dnx_sec|
              hash_md[dnx_sec[:id]] = dnx_sec.xpath('dnx:record', NS).inject([]) do |records, dnx_record|
                records << dnx_record.xpath('dnx:key', NS).inject({}) do |record_hash, key|
                  record_hash[key[:id]] = key.content
                  record_hash
                end
                records
              end
              hash_md
            end
            hash_sec
          end
          hash_amd
        end
        rep_sec = xml_doc.root.xpath('.//mets:fileGrp', NS).inject({}) do |hash_rep, rep|
          hash_rep[rep[:ID]] = {
              amd: amd_sec[rep[:ADMID]],
              dmd: amd_sec[rep[:DMDID]]
          }.cleanup.merge(
              rep.xpath('mets:file', NS).inject({}) do |hash_file, file|
                hash_file[file[:ID]] = {
                    group: file[:GROUPID],
                    amd: amd_sec[file[:ADMID]],
                    dmd: dmd_sec[file[:DMDID]],
                }.cleanup
                hash_file
              end
          )
          hash_rep
        end
        { amd: amd_sec['ie-amd'],
          dmd: dmd_sec['ie-dmd'],
        }.cleanup.merge(
            xml_doc.root.xpath('.//mets:structMap[@TYPE="PHYSICAL"]', NS).inject({}) do |hash_map, map|
              rep_id = map[:ID].gsub(/-\d+$/, '')
              rep = rep_sec[rep_id]
              div_parser = lambda do |div|
                if div[:TYPE] == 'FILE'
                  file_id = div.xpath('mets:fptr').first[:FILEID]
                  {
                      id: file_id
                  }.merge rep[file_id]
                else
                  div.children.inject({}) do |hash, child|
                    # noinspection RubyScope
                    hash[child[:LABEL]] = div_parser.call(child)
                    hash
                  end
                end
              end
              hash_map[map.xpath('mets:div').first[:LABEL]] = {
                  id: rep_id,
                  amd: rep_sec[rep_id][:amd],
                  dmd: rep_sec[rep_id][:dmd],
              }.cleanup.merge(
                  map.xpath('mets:div', NS).inject({}) do |hash, div|
                    hash[div[:LABEL]] = div_parser.call(div)
                  end
              )
              hash_map
            end
        )
      end

      def dc_record=(xml)
        @dc_record = xml
      end

      def amd_info=(hash)
        @dnx = {}
        tech_data = []
        data = {
            IEEntityType: hash[:entity_type],
            UserDefinedA: hash[:user_a],
            UserDefinedB: hash[:user_b],
            UserDefinedC: hash[:user_c],
            status: hash[:status],
        }.cleanup
        tech_data << TechGeneralIE.new(data) unless data.empty?
        data = {
            policyId: hash[:retention_id],
        }.cleanup
        tech_data << RetentionPeriod.new(data) unless data.empty?
        @dnx[:tech] = tech_data unless tech_data.empty?
        data = {
            policyId: hash[:access_right]
        }.cleanup
        rights_data = []
        rights_data << Rights.new(data) unless data.empty?
        @dnx[:rights] = rights_data unless rights_data.empty?
      end

      # @param [Hash] hash
      # @return [LIBIS::Tools::MetsFile::Representation]
      def representation(hash = {})
        rep = Representation.new
        rep.set_from_hash hash
        @representations[rep.id] = rep
      end

      # @param [Hash] hash
      # @return [LIBIS::Tools::MetsFile::Div]
      def div(hash = {})
        div = LIBIS::Tools::MetsFile::Div.new
        div.set_from_hash hash
        @divs[div.id] = div
      end

      # @param [Hash] hash
      # @return [LIBIS::Tools::MetsFile::File]
      def file(hash = {})
        file = LIBIS::Tools::MetsFile::File.new
        file.set_from_hash hash
        @files[file.id] = file
      end

      # @param [LIBIS::Tools::MetsFile::Representation] rep
      # @param [LIBIS::Tools::MetsFile::Div] div
      # @return [LIBIS::Tools::MetsFile::Map]
      def map(rep, div)
        map = LIBIS::Tools::MetsFile::Map.new
        map.representation = rep
        map.div = div
        @maps[map.id] = map
      end

      # @return [LIBIS::Tools::XmlDocument]
      def xml_doc
        ::LIBIS::Tools::XmlDocument.build do |xml|
          xml[:mets].mets(
              'xmlns:mets' => NS[:mets],
          ) {
            add_dmd(xml)
            add_amd(xml)
            add_filesec(xml)
            add_struct_map(xml)
          }
        end
      end

      protected

      def dmd_id(id)
        "#{id}-dmd"
      end

      def amd_id(id)
        "#{id}-amd"
      end

      def add_dmd(xml, object = nil)
        case object
          when NilClass
            add_dmd_section(xml, 'ie', @dc_record)
            # @representations.values.each { |rep| add_dmd(xml, rep) }
            @files.values.each { |file| add_dmd(xml, file) }
          when LIBIS::Tools::MetsFile::File
            add_dmd_section(xml, object.xml_id, object.dc_record)
          # when Representation
          #   add_dmd_section(xml, object.xml_id, object.dc_record)
          else
            raise RuntimeError, "Unsupported object type: #{object.class}"
        end
      end

      def add_amd(xml, object = nil)
        case object
          when NilClass
            raise RuntimeError, 'No IE amd info present.' unless @dnx
            add_amd_section(xml, 'ie', @dnx)
            @representations.values.each { |rep| add_amd(xml, rep) }
            @files.values.each { |file| add_amd(xml, file) }
          when LIBIS::Tools::MetsFile::File
            add_amd_section(xml, object.xml_id, object.amd)
            object.manifestations.each { |manif| add_amd_section(xml, manif.xml_id, manif.amd) }
          when LIBIS::Tools::MetsFile::Representation
            add_amd_section(xml, object.xml_id, object.amd)
          else
            raise RuntimeError, "Unsupported object type: #{object.class}"
        end
      end

      def add_filesec(xml, object = nil, representation = nil)
        case object
          when NilClass
            xml[:mets].fileSec {
              @representations.values.each { |rep| add_filesec(xml, rep) }
            }
          when LIBIS::Tools::MetsFile::Representation
            h = {
                ID: object.xml_id,
                USE: object.usage_type,
                ADMID: amd_id(object.xml_id),
                # DDMID: dmd_id(object.xml_id),
            }.cleanup
            xml[:mets].fileGrp(h) {
              @files.values.each { |obj| add_filesec(xml, obj, object) }
            }
          when LIBIS::Tools::MetsFile::File
            if object.representation == representation
              h = {
                  ID: object.xml_id,
                  MIMETYPE: object.mimetype,
                  ADMID: amd_id(object.xml_id),
                  GROUPID: object.group_id,
              }.cleanup
              h[:DMDID] = dmd_id(object.xml_id) if object.dc_record

              xml[:mets].file(h) {
                # noinspection RubyStringKeysInHashInspection
                xml[:mets].FLocat(
                    LOCTYPE: 'URL',
                    'xmlns:xlin' => NS[:xlin],
                    'xlin:href' => object.target_location,
                )
              }
            end
          else
            raise RuntimeError, "Unsupported object type: #{object.class}"
        end
      end

      def add_struct_map(xml, object = nil)
        case object
          when NilClass
            @maps.values.each do |map|
              xml[:mets].structMap(
                  ID: "#{map.representation.xml_id}-1",
                  TYPE: 'PHYSICAL',
              ) {
                xml[:mets].div(LABEL: map.representation.label) {
                  add_struct_map(xml, map.div) if map.div
                }
              }
            end
          when LIBIS::Tools::MetsFile::Div
            h = {
                LABEL: object.label,
            }.cleanup
            xml[:mets].div(h) {
              object.files.each { |file| add_struct_map(xml, file) }
              object.divs.each { |div| add_struct_map(xml, div) }
            }
          when LIBIS::Tools::MetsFile::File
            h = {
                LABEL: object.label,
                TYPE: 'FILE',
            }.cleanup
            xml[:mets].div(h) {
              xml[:mets].fptr(FILEID: object.xml_id)
            }
          else
            raise RuntimeError, "Unsupported object type: #{object.class}"
        end

      end

      def add_dmd_section(xml, id, dc_record = nil)
        return if dc_record.nil?
        xml[:mets].dmdSec(ID: dmd_id(id)) {
          xml[:mets].mdWrap(MDTYPE: 'DC') {
            xml[:mets].xmlData {
              xml << dc_record
            }
          }
        }
      end

      def add_amd_section(xml, id, dnx_sections = {})
        xml[:mets].amdSec(ID: amd_id(id)) {
          [:tech, :rights, :source, :digiprov].each do |section_type|
            xml.send("#{section_type}MD", ID: "#{amd_id(id)}-#{section_type.to_s}") {
              xml[:mets].mdWrap(MDTYPE: 'OTHER', OTHERMDTYPE: 'dnx') {
                xml[:mets].xmlData {
                  add_dnx_sections(xml, dnx_sections[section_type])
                }
              }
            }
          end
        }
      end

      def add_dnx_sections(xml, section_data)
        section_data ||= []
        xml[:mets].dnx(xmlns: NS[:dnx]) {
          (section_data).each do |section|
            xml.section(id: section.tag) {
              xml.record {
                section.each_pair do |key, value|
                  next if value.nil?
                  xml.key(value, id: key)
                end
              }
            }
          end
        }
      end

      def parse_div(div, rep)
        if div[:TYPE] == 'FILE'
          file_id = div.children.first[:FILEID]
          {
              id: file_id
          }.merge rep[file_id]
        else
          div.children.inject({}) do |hash, child|
            hash[child[:LABEL]] = parse_div child, rep
            hash
          end
        end
      end

    end

  end
end
