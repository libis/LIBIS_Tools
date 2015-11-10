# encoding: utf-8
require 'ostruct'

require 'libis/tools/extend/hash'
require_relative 'xml_document'

module Libis
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

        attr_accessor :label, :preservation_type, :usage_type, :representation_code, :entity_type, :priority, :order,
                      :digital_original, :content, :context, :hardware, :carrier, :original_name,
                      :user_a, :user_b, :user_c, :group_id,
                      :preservation_levels, :env_dependencies, :hardware_ids, :software_ids,
                      :hardware_infos, :software_infos, :relationship_infos, :environments,
                      :dc_record, :source_metadata

        def xml_id
          "rep#{id}"
        end

        def amd
          dnx = {}
          tech_data = []
          # General characteristics
          data = {
              preservationType: preservation_type,
              usageType: usage_type,
              DigitalOriginal: digital_original,
              label: label,
              representationEntityType: entity_type,
              contentType: content,
              contextType: context,
              hardwareUsed: hardware,
              physicalCarrierMedia: carrier,
              deliveryPriority: priority,
              orderingSequence: order,
              RepresentationCode: representation_code,
              RepresentationOriginalName: original_name,
              UserDefinedA: user_a,
              UserDefinedB: user_b,
              UserDefinedC: user_c,
          }.cleanup
          tech_data << TechGeneralRep.new(data) unless data.empty?
          # Object characteristics
          data = {
              groupID: group_id
          }.cleanup
          tech_data << TechObjectChars.new(data) unless data.empty?
          # Preservation level
          if preservation_levels
            data_list = []
            preservation_levels.each do |preservation_level|
              data = {
                  preservationLevelValue: preservation_level[:value],
                  preservationLevelRole: preservation_level[:role],
                  preservationLevelRationale: preservation_level[:rationale],
                  preservationLevelDateAssigned: preservation_level[:date],
              }.cleanup
              data_list << OpenStruct.new(data) unless data.empty?
            end
            tech_data << PreservationLevel.new(array: data_list) unless data_list.empty?
          end
          # Dependencies
          if env_dependencies
            data_list = []
            env_dependencies.each do |dependency|
              data = {
                  dependencyName: dependency[:name],
                  dependencyIdentifierType1: dependency[:type1],
                  dependencyIdentifierValue1: dependency[:value1],
                  dependencyIdentifierType2: dependency[:type2],
                  dependencyIdentifierValue2: dependency[:value2],
                  dependencyIdentifierType3: dependency[:type3],
                  dependencyIdentifierValue3: dependency[:value3],
              }.cleanup
              data_list << OpenStruct.new(data) unless data.empty?
            end
            tech_data << EnvDeps.new(array: data_list) unless data_list.empty?
          end
          # Hardware registry id
          if hardware_ids
            data_list = []
            hardware_ids.each do |id|
              data = {
                  registryId: id
              }.cleanup
              data_list << OpenStruct.new(data) unless data.empty?
            end
            tech_data << HardwareId.new(array: data_list) unless data_list.empty?
          end
          # Software registry id
          if software_ids
            data_list = []
            software_ids.each do |id|
              data = {
                  registryId: id
              }.cleanup
              data_list << OpenStruct.new(data) unless data.empty?
            end
            tech_data << SoftwareId.new(array: data_list) unless data_list.empty?
          end
          # Hardware
          if hardware_infos
            data_list = []
            hardware_infos.each do |hardware|
              data = {
                  hardwareName: hardware[:name],
                  hardwareType: hardware[:type],
                  hardwareOtherInformation: hardware[:info],
              }.cleanup
              data_list << OpenStruct.new(data) unless data.empty?
            end
            tech_data << HardwareInfo.new(array: data_list) unless data_list.empty?
          end
          # Software
          if software_infos
            data_list = []
            software_infos.each do |software|
              data = {
                  softwareName: software[:name],
                  softwareVersion: software[:version],
                  softwareType: software[:type],
                  softwareOtherInformation: software[:info],
                  softwareDependancy: software[:dependency],
              }.cleanup
              data_list << OpenStruct.new(data) unless data.empty?
            end
            tech_data << SoftwareInfo.new(array: data_list) unless data_list.empty?
          end
          # Relationship
          if relationship_infos
            data_list = []
            relationship_infos.each do |relationship|
              data = {
                  relationshipType: relationship[:type],
                  relationshipSubType: relationship[:subtype],
                  relatedObjectIdentifierType1: relationship[:type1],
                  relatedObjectIdentifierValue1: relationship[:id1],
                  relatedObjectSequence1: relationship[:seq1],
                  relatedObjectIdentifierType2: relationship[:type2],
                  relatedObjectIdentifierValue2: relationship[:id2],
                  relatedObjectSequence2: relationship[:seq2],
                  relatedObjectIdentifierType3: relationship[:type3],
                  relatedObjectIdentifierValue3: relationship[:id3],
                  relatedObjectSequence3: relationship[:seq3],
              }.cleanup
              data_list << OpenStruct.new(data) unless data.empty?
            end
            tech_data << RelationShip.new(array: data_list) unless data_list.empty?
          end
          # Environment
          if environments
            data_list = []
            environments.each do |environment|
              data = {
                  environmentCharacteristic: environment[:characteristic],
                  environmentPurpose: environment[:purpose],
                  environmentNote: environment[:note],
              }.cleanup
              data_list << OpenStruct.new(data) unless data.empty?
            end
            tech_data << Environment.new(array: data_list) unless data_list.empty?
          end
          # Finally assemble technical section
          dnx[:tech] = tech_data unless tech_data.empty?
          # Rights section
          rights_data = []
          data = {
              policyId: hash[:access_right]
          }.cleanup
          rights_data << Rights.new(data) unless data.empty?
          dnx[:rights] = rights_data unless rights_data.empty?
          # Source metadata
          if source_metadata
            source_metadata.each_with_index do |metadata, i|
              dnx["source-#{metadata[:type].to_s.upcase}-#{i}"] = metadata[:data]
            end
          end
          dnx
        end

      end

      class File
        include IdContainer

        attr_accessor :label, :note, :location, :target_location, :mimetype, :entity_type,
                      :creation_date, :modification_date, :composition_level, :group_id,
                      :fixity_type, :fixity_value,
                      :preservation_levels, :inhibitors, :env_dependencies, :hardware_ids, :software_ids,
                      :signatures, :hardware_infos, :software_infos, :relationship_infos, :environments, :applications,
                      :dc_record, :source_metadata
        :representation

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
          # General File charateristics
          data = {
              label: label,
              note: note,
              fileCreationDate: creation_date,
              fileModificationDate: modification_date,
              FileEntityType: entity_type,
              compositionLevel: composition_level,
              # fileLocationType: 'FILE',
              # fileLocation: '',
              fileOriginalName: orig_name,
              fileOriginalPath: orig_path,
              fileOriginalID: location,
              fileExtension: ::File.extname(orig_name),
              fileMIMEType: mimetype,
              fileSizeBytes: size,

          }.cleanup
          tech_data << TechGeneralFile.new(data) unless data.empty?
          # Fixity
          data = {
              fixityType: fixity_type,
              fixityValue: fixity_value,
          }.cleanup
          tech_data << TechFixity.new(data) unless data.empty?
          # Object characteristics
          data = {
              groupID: group_id
          }.cleanup
          tech_data << TechObjectChars.new(data) unless data.empty?
          # Preservation level
          if preservation_levels
            data_list = []
            preservation_levels.each do |preservation_level|
              data = {
                  preservationLevelValue: preservation_level[:value],
                  preservationLevelRole: preservation_level[:role],
                  preservationLevelRationale: preservation_level[:rationale],
                  preservationLevelDateAssigned: preservation_level[:date],
              }.cleanup
              data_list << OpenStruct.new(data) unless data.empty?
            end
            tech_data << PreservationLevel.new(array: data_list) unless data_list.empty?
          end
          # Inhibitor
          if inhibitors
            data_list = []
            inhibitors.each do |inhibitor|
              data = {
                  inhibitorType: inhibitor[:type],
                  inhibitorTarget: inhibitor[:target],
                  inhibitorKey: inhibitor[:key],
              }.cleanup
              data_list << OpenStruct.new(data) unless data.empty?
            end
            tech_data << Inhibitor.new(array: data_list) unless data_list.empty?
          end
          # Dependencies
          if env_dependencies
            data_list = []
            env_dependencies.each do |dependency|
              data = {
                  dependencyName: dependency[:name],
                  dependencyIdentifierType1: dependency[:type1],
                  dependencyIdentifierValue1: dependency[:value1],
                  dependencyIdentifierType2: dependency[:type2],
                  dependencyIdentifierValue2: dependency[:value2],
                  dependencyIdentifierType3: dependency[:type3],
                  dependencyIdentifierValue3: dependency[:value3],
              }.cleanup
              data_list << OpenStruct.new(data) unless data.empty?
            end
            tech_data << EnvDeps.new(array: data_list) unless data_list.empty?
          end
          # Hardware registry id
          if hardware_ids
            data_list = []
            hardware_ids.each do |id|
              data = {
                  registryId: id
              }.cleanup
              data_list << OpenStruct.new(data) unless data.empty?
            end
            tech_data << HardwareId.new(array: data_list) unless data_list.empty?
          end
          # Software registry id
          if software_ids
            data_list = []
            software_ids.each do |id|
              data = {
                  registryId: id
              }.cleanup
              data_list << OpenStruct.new(data) unless data.empty?
            end
            tech_data << SoftwareId.new(array: data_list) unless data_list.empty?
          end
          # Singatures
          if signatures
            data_list = []
            signatures.each do |signature|
              data = {
                  signatureInformationEncoding: signature[:encoding],
                  signer: signature[:signer],
                  signatureMethod: signature[:method],
                  signatureValue: signature[:value],
                  signatureValidationRules: signature[:rules],
                  signatureProperties: signature[:properties],
              }.cleanup
              data_list << OpenStruct.new(data) unless data.empty?
            end
            tech_data << Signature.new(array: data_list) unless data_list.empty?
          end
          # Hardware
          if hardware_infos
            data_list = []
            hardware_infos.each do |hardware|
              data = {
                  hardwareName: hardware[:name],
                  hardwareType: hardware[:type],
                  hardwareOtherInformation: hardware[:info],
              }.cleanup
              data_list << OpenStruct.new(data) unless data.empty?
            end
            tech_data << HardwareInfo.new(array: data_list) unless data_list.empty?
          end
          # Software
          if software_infos
            data_list = []
            software_infos.each do |software|
              data = {
                  softwareName: software[:name],
                  softwareVersion: software[:version],
                  softwareType: software[:type],
                  softwareOtherInformation: software[:info],
                  softwareDependancy: software[:dependency],
              }.cleanup
              data_list << OpenStruct.new(data) unless data.empty?
            end
            tech_data << SoftwareInfo.new(array: data_list) unless data_list.empty?
          end
          # Relationship
          if relationship_infos
            data_list = []
            relationship_infos.each do |relationship|
              data = {
                  relationshipType: relationship[:type],
                  relationshipSubType: relationship[:subtype],
                  relatedObjectIdentifierType1: relationship[:type1],
                  relatedObjectIdentifierValue1: relationship[:id1],
                  relatedObjectSequence1: relationship[:seq1],
                  relatedObjectIdentifierType2: relationship[:type2],
                  relatedObjectIdentifierValue2: relationship[:id2],
                  relatedObjectSequence2: relationship[:seq2],
                  relatedObjectIdentifierType3: relationship[:type3],
                  relatedObjectIdentifierValue3: relationship[:id3],
                  relatedObjectSequence3: relationship[:seq3],
              }.cleanup
              data_list << OpenStruct.new(data) unless data.empty?
            end
            tech_data << RelationShip.new(array: data_list) unless data_list.empty?
          end
          # Environment
          if environments
            data_list = []
            environments.each do |environment|
              data = {
                  environmentCharacteristic: environment[:characteristic],
                  environmentPurpose: environment[:purpose],
                  environmentNote: environment[:note],
              }.cleanup
              data_list << OpenStruct.new(data) unless data.empty?
            end
            tech_data << Environment.new(array: data_list) unless data_list.empty?
          end
          # Application
          if applications
            data_list = []
            applications.each do |application|
              data = {
                  creatingApplicationName: application[:name],
                  creatingApplicationVersion: application[:version],
                  dateCreatedByApplication: application[:date],
              }.cleanup
              data_list << OpenStruct.new(data) unless data.empty?
            end
            tech_data << Application.new(array: data_list) unless data_list.empty?
          end
          # Finally assemble technical section
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

      class TechObjectChars < DnxSection
        tag 'objectCharacteristics'
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

      class WebHarvesting < DnxSection
        tag 'webHarvesting'
      end

      class PreservationLevel < DnxSection
        tag 'preservationLevel'
      end

      class EnvDeps < DnxSection
        tag 'environmentDependencies'
      end

      class HardwareId < DnxSection
        tag 'envHardwareRegistry'
      end

      class SoftwareId < DnxSection
        tag 'envSoftwareRegistry'
      end

      class HardwareInfo < DnxSection
        tag 'environmentHardware'
      end

      class SoftwareInfo < DnxSection
        tag 'environmentSoftware'
      end

      class Relationship < DnxSection
        tag 'relationship'
      end

      class Environment < DnxSection
        tag 'environment'
      end

      class Inhibitor < DnxSection
        tag 'inhibitors'
      end

      class Signature < DnxSection
        tag 'signatureInformation'
      end

      class Application < DnxSection
        tag 'creatingApplication'
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
        @dnx = {}
        @dc_record = nil
      end

      def self.parse(xml)
        xml_doc = case xml
                    when String
                      Libis::Tools::XmlDocument.parse(xml).document
                    when Hash
                      Libis::Tools::XmlDocument.from_hash(xml).document
                    when Libis::Tools::XmlDocument
                      xml.document
                    when Nokogiri::XML::Document
                      xml
                    else
                      raise ArgumentError, "Libis::Tools::MetsFile#parse does not accept input of type #{xml.class}"
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
        {amd: amd_sec['ie-amd'],
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
            groupID: hash[:group_id]
        }.cleanup
        tech_data << TechObjectChars.new(data) unless data.empty?
        data = {
            status: hash[:status],
            IEEntityType: hash[:entity_type],
            UserDefinedA: hash[:user_a],
            UserDefinedB: hash[:user_b],
            UserDefinedC: hash[:user_c],
            submissionReason: hash[:submission_reason],
        }.cleanup
        tech_data << TechGeneralIE.new(data) unless data.empty?
        data = {
            policyId: hash[:retention_id],
        }.cleanup
        tech_data << RetentionPeriod.new(data) unless data.empty?
        data = {
            primarySeedURL: hash[:harvest_url],
            WCTIdentifier: hash[:harvest_id],
            targetName: hash[:harvest_target],
            group: hash[:harvest_group],
            harvestDate: hash[:harvest_date],
            harvestTime: hash[:harvest_time],
        }.cleanup
        tech_data << WebHarvesting.new(data) unless data.empty?
        @dnx[:tech] = tech_data unless tech_data.empty?
        data = {
            policyId: hash[:access_right]
        }.cleanup
        rights_data = []
        rights_data << Rights.new(data) unless data.empty?
        @dnx[:rights] = rights_data unless rights_data.empty?
        (hash[:source_metadata] || []).each_with_index do |metadata, i|
          @dnx["source-#{metadata[:type].to_s.upcase}-#{i+1}"] = metadata[:data]
        end
      end

      # @param [Hash] hash
      # @return [Libis::Tools::MetsFile::Representation]
      def representation(hash = {})
        rep = Representation.new
        rep.set_from_hash hash
        @representations[rep.id] = rep
      end

      # @param [Hash] hash
      # @return [Libis::Tools::MetsFile::Div]
      def div(hash = {})
        div = Libis::Tools::MetsFile::Div.new
        div.set_from_hash hash
        @divs[div.id] = div
      end

      # @param [Hash] hash
      # @return [Libis::Tools::MetsFile::File]
      def file(hash = {})
        file = Libis::Tools::MetsFile::File.new
        file.set_from_hash hash
        @files[file.id] = file
      end

      # @param [Libis::Tools::MetsFile::Representation] rep
      # @param [Libis::Tools::MetsFile::Div] div
      # @return [Libis::Tools::MetsFile::Map]
      def map(rep, div)
        map = Libis::Tools::MetsFile::Map.new
        map.representation = rep
        map.div = div
        @maps[map.id] = map
      end

      # @return [Libis::Tools::XmlDocument]
      def xml_doc
        ::Libis::Tools::XmlDocument.build do |xml|
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
          when Libis::Tools::MetsFile::File
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
          when Libis::Tools::MetsFile::File
            add_amd_section(xml, object.xml_id, object.amd)
            object.manifestations.each { |manif| add_amd_section(xml, manif.xml_id, manif.amd) }
          when Libis::Tools::MetsFile::Representation
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
          when Libis::Tools::MetsFile::Representation
            h = {
                ID: object.xml_id,
                USE: object.usage_type,
                ADMID: amd_id(object.xml_id),
                # DDMID: dmd_id(object.xml_id),
            }.cleanup
            xml[:mets].fileGrp(h) {
              @files.values.each { |obj| add_filesec(xml, obj, object) }
            }
          when Libis::Tools::MetsFile::File
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
                  add_struct_map(xml, map.diqv) if map.div
                }
              }
            end
          when Libis::Tools::MetsFile::Div
            h = {
                LABEL: object.label,
            }.cleanup
            xml[:mets].div(h) {
              object.files.each { |file| add_struct_map(xml, file) }
              object.divs.each { |div| add_struct_map(xml, div) }
            }
          when Libis::Tools::MetsFile::File
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
              xml[:dc] << dc_record
            }
          }
        }
      end

      def add_amd_section(xml, id, dnx_sections = {})
        xml[:mets].amdSec(ID: amd_id(id)) {
          dnx_sections.each do |section_type, data|
            if section_type.to_s =~ /^source-(.*)-\d+$/
              xml.send('sourceMD', ID: "#{amd_id(id)}-#{section_type.to_s}") {
                xml[:mets].mdWrap(MDTYPE: $1) {
                  xml[:mets].xmlData {
                    xml << data
                  }
                }
              }
            else
              xml.send("#{section_type}MD", ID: "#{amd_id(id)}-#{section_type.to_s}") {
                xml[:mets].mdWrap(MDTYPE: 'OTHER', OTHERMDTYPE: 'dnx') {
                  xml[:mets].xmlData {
                    add_dnx_sections(xml, data)
                  }
                }
              }
            end
          end
        }
      end

      def add_dnx_sections(xml, section_data)
        section_data ||= []
        xml.dnx(xmlns: NS[:dnx]) {
          (section_data).each do |section|
            xml.section(id: section.tag) {
              records = section[:array] || [section]
              records.each do |data|
                xml.record {
                  data.each_pair do |key, value|
                    next if value.nil?
                    xml.key(value, id: key)
                  end
                }
              end
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
