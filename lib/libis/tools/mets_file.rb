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
          "rep-#{id}"
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
          tech_data << TechGeneral.new(data) unless data.empty?
          dnx[:tech] = tech_data unless tech_data.empty?
          dnx
        end

      end

      class File
        include IdContainer

        attr_accessor :label, :location, :mimetype, :size, :fixity_type, :fixity_value, :entity_type, :representation, :dc_record

        def xml_id
          "file-#{id}"
        end

        def group_id
          "grp-#{master.id rescue id}"
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

        def target_location
          "#{xml_id}#{::File.extname(location)}"
        end

        def amd
          dnx = {}
          tech_data = []
          data = {
              label: label,
              fileMIMEType: mimetype,
              fileOriginalName: orig_name,
              fileOriginalPath: orig_path,
              fileEntityType: entity_type,
              fileSizeBytes: size,
          }.cleanup
          tech_data << TechGeneral.new(data) unless data.empty?
          data = {
              fixityType: fixity_type,
              fixityValue: fixity_value,
          }.cleanup
          tech_data << TechFixity.new(data) unless data.empty?
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
        def self.tag(value = nil, klass = nil)
          var_name = "@tag#{klass.to_s.capitalize}"
          if value.nil?
            var_name = instance_variables.include?(var_name) ? var_name : '@tag'
            instance_variable_get(var_name)
          else
            instance_variable_set(var_name, value)
          end
        end

        def tag(klass = nil)
          self.class.tag(nil, klass)
        end
      end

      class TechGeneral < DnxSection
        tag 'generalFileCharacteristics', :File
        tag 'generalRepCharacteristics', :Representation
      end

      class TechFixity < DnxSection
        tag 'fileFixity'
      end

      class Rights < DnxSection
        tag 'accessRightsPolicy'
      end

      attr_reader :representations, :files, :divs, :maps

      def initialize
        @representations = {}
        @files = {}
        @divs = {}
        @maps = {}
      end

      def dc_record=(xml)
        @dc_record = xml
      end

      def amd_info=(hash)
        @dnx = {}
        data = {
            IEEntityType: hash[:entity_type],
            UserDefinedA: hash[:user_a],
            UserDefinedB: hash[:user_b],
            UserDefinedC: hash[:user_c],
            status: hash[:status],
        }.cleanup
        tech_data = []
        tech_data << TechGeneral.new(data) unless data.empty?
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
              # 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
              'xmlns:mets' => 'http://www.loc.gov/METS/',
              # 'xmlns:mets' => 'http://www.exlibrisgroup.com/xsd/dps/rosettaMets',
          # 'xmlns:mets' => 'file:///home/kris/mets_rosetta.xsd',
          # 'xmlns:xlink' => 'http://www.w3.org/TR/xlink',
          # 'xmlns:mods' => 'http://www.loc.gov/mods/',
          # 'xmlns' => 'file:///home/kris/mets_rosetta.xsd',
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
            add_amd_section(xml, object.xml_id, object.amd, :File)
            object.manifestations.each { |manif| add_amd_section(xml, manif.xml_id, manif.amd, :File) }
          when LIBIS::Tools::MetsFile::Representation
            add_amd_section(xml, object.xml_id, object.amd, :Rep)
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
                  ADMID: amd_id(object.xml_id),
                  GROUPID: object.group_id,
                  MIMETYPE: object.mimetype,
              }.cleanup
              h[:DMDID] = dmd_id(object.xml_id) if object.dc_record

              xml[:mets].file(h) {
                # noinspection RubyStringKeysInHashInspection
                xml[:mets].FLocat(
                    LOCTYPE: 'URL',
                    'xmlns:xlin' => 'http://www.w3.org/1999/xlink',
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
                add_struct_map(xml, map.div) if map.div
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

      def add_amd_section(xml, id, dnx_sections = {}, klass = nil)
        xml[:mets].amdSec(ID: amd_id(id)) {
          [:tech, :rights, :source, :digiprov].each do |section_type|
            xml.send("#{section_type}MD", ID: "#{amd_id(id)}-#{section_type.to_s}") {
              xml[:mets].mdWrap(MDTYPE: 'OTHER', OTHERMDTYPE: 'dnx') {
                xml[:mets].xmlData {
                  add_dnx_sections(xml, dnx_sections[section_type], klass)
                }
              }
            }
          end
        }
      end

      def add_dnx_sections(xml, section_data, klass = nil)
        section_data ||= []
        xml[:mets].dnx(xmlns: 'http://www.exlibrisgroup.com/dps/dnx') {
          (section_data).each do |section|
            xml.section(id: section.tag(klass)) {
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

    end

  end
end
