require 'libis/tools/thread_safe'
require 'cgi'

module Libis
  module Tools
    # noinspection RubyResolve
    class MetsFile

      # Generic module that provides code shortcuts for the {Representation}, {Div} and {File} classes.
      module MetsObject

        # Take a hash and set class instance attributes.
        # @param [Hash] hash Hash with <attribute_name>, <attribute_value> pairs.
        def set_from_hash(hash)
          hash.each { |key, value| send "#{key}=", value if respond_to?(key) }
        end

        # Default initializer
        def initialize
          @id = 0
        end

        # Sets the unique id for the instance
        def set_id(id)
          @id = id
        end

        def id
          @id
        end

        # Convert structure to String. Can be used for debugging to show what is stored.
        def to_s
          "#{self.class}:\n" +
              self.instance_variables.map do |var|
                v = self.instance_variable_get(var)
                v = "#{v.class}-#{v.id}" if v.is_a? MetsObject
                v = v.map do |x|
                  x.is_a?(MetsObject) ? "#{x.class}-#{x.id}" : x.to_s
                end.join(',') if v.is_a? Array
                " - #{var.to_s.gsub(/^@/, '')}: #{v}"
              end.join("\n")
        end

      end

      # Container class for creating a file in the METS.
      class File
        include MetsObject

        # The currently allowed attributes on this class. The attributes will typically be used in {DnxSection}s.
        attr_accessor :label, :note, :location, :target_location, :original, :mimetype, :puid, :size, :entity_type,
                      :creation_date, :modification_date, :composition_level, :group_id,
                      :checksum_MD5, :checksum_SHA1, :checksum_SHA256,:checksum_SHA384,:checksum_SHA512,
                      :fixity_type, :fixity_value,
                      :preservation_levels, :inhibitors, :env_dependencies, :hardware_ids, :software_ids,
                      :signatures, :hardware_infos, :software_infos, :relationship_infos, :environments, :applications,
                      :dc_record, :source_metadata, :representation

        # The id that will be used in the XML file to reference this file.
        def xml_id
          "fid#{@id}"
        end

        # The id that will be used for the group in the XML file.
        def make_group_id
          "grp#{group_id rescue @id}"
        end

        # The file's name as it was originally.
        def orig_name
          ::File.basename(location)
        end

        # The file's original directory.
        def orig_path
          ::File.dirname(location)
        end

        # The full path where the file is copied
        def target
          if target_location.nil?
            return "#{xml_id}#{::File.extname(location)}"
          end
          target_location
        end

        def target_name
          ::File.basename(target)
        end

        def target_path
          ::File.dirname(target)
        end

        # This method creates the appropriate {DnxSection}s based on what attributes are filled in.
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
              fileLocation: location,
              fileOriginalName: original || target_name,
              fileOriginalPath: target_path,
              # fileOriginalID: CGI.escape(location),
              # fileExtension: ::File.extname(orig_name),
              fileMIMEType: mimetype,
              fileSizeBytes: size,
              # formatLibraryId: puid
          }.cleanup
          tech_data << GeneralFileCharacteristics.new(data) unless data.empty?
          # Fixity
          %w'MD5 SHA1 SHA256 SHA384 SHA512'.each do |checksum_type|
            if (checksum = self.send("checksum_#{checksum_type}"))
              data = {
                  fixityType: checksum_type,
                  fixityValue: checksum,
              }.cleanup
              tech_data << FileFixity.new(data) unless data.empty?
            end
          end
          # Object characteristics
          data = {
              groupID: make_group_id
          }.cleanup
          tech_data << ObjectCharacteristics.new(data) unless data.empty?
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
            tech_data << Inhibitors.new(array: data_list) unless data_list.empty?
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
            tech_data << EnvironmentDependencies.new(array: data_list) unless data_list.empty?
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
            tech_data << EnvHardwareRegistry.new(array: data_list) unless data_list.empty?
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
            tech_data << EnvSoftwareRegistry.new(array: data_list) unless data_list.empty?
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
            tech_data << SignatureInformation.new(array: data_list) unless data_list.empty?
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
            tech_data << EnvironmentHardware.new(array: data_list) unless data_list.empty?
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
            tech_data << EnvironmentSoftware.new(array: data_list) unless data_list.empty?
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
            tech_data << CreatingApplication.new(array: data_list) unless data_list.empty?
          end
          # Finally assemble technical section
          dnx[:tech] = tech_data unless tech_data.empty?
          dnx
        end

      end

      # Container class for creating a division in the METS.
      class Div
        include MetsObject
        include Libis::Tools::ThreadSafe

        attr_accessor :label

        # The id that will be used in the XML file to reference this division.
        def xml_id
          "div-#{@id}"
        end

        # All items stored in the current division
        def children
          files + divs
        end

        # All file items stored in the current division
        def files
          self.mutex.synchronize do
            @files ||= Array.new
          end
        end

        # All division items stored in the current division
        def divs
          self.mutex.synchronize do
            @divs ||= Array.new
          end
        end

        # Add an item ({File} or {Div}) to the current division
        def <<(obj)
          self.mutex.synchronize do
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

      end

      # Container class for creating a representation in the METS.
      class Representation
        include MetsObject

        # The currently allowed attributes on this class. The attributes will typically be used in {DnxSection}s.
        attr_accessor :preservation_type, :usage_type, :representation_code, :entity_type, :access_right_id,
                      :user_a, :user_b, :user_c,
                      :group_id, :priority, :order,
                      :digital_original, :content, :context, :hardware, :carrier, :original_name,
                      :preservation_levels, :env_dependencies, :hardware_ids, :software_ids,
                      :hardware_infos, :software_infos, :relationship_infos, :environments,
                      :dc_record, :source_metadata

        # The id that will be used in the XML file to reference this representation.
        def xml_id
          "rep#{@id}"
        end

        # This method creates the appropriate {DnxSection}s based on what attributes are filled in.
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
          tech_data << GeneralRepCharacteristics.new(data) unless data.empty?
          # Object characteristics
          data = {
              groupID: group_id
          }.cleanup
          tech_data << ObjectCharacteristics.new(data) unless data.empty?
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
            tech_data << EnvironmentDependencies.new(array: data_list) unless data_list.empty?
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
            tech_data << EnvHardwareRegistry.new(array: data_list) unless data_list.empty?
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
            tech_data << EnvSoftwareRegistry.new(array: data_list) unless data_list.empty?
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
            tech_data << EnvironmentHardware.new(array: data_list) unless data_list.empty?
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
            tech_data << EnvironmentSoftware.new(array: data_list) unless data_list.empty?
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
              policyId: access_right_id
          }.cleanup
          rights_data << AccessRightsPolicy.new(data) unless data.empty?
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

      # Container class for creating a structmap in the METS.
      class Map
        include MetsObject

        # The representation this structmap is for
        attr_accessor :representation
        # The top division in the structmap
        attr_accessor :div
        # Is the structmap Logical (true) or Physical(false)?
        attr_accessor :is_logical

        # The id that will be used in the XML file to reference this structmap.
        def xml_id
          "smap-#{@id}"
        end

      end

    end
  end
end