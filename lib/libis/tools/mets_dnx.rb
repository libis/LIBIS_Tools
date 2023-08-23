module Libis
  module Tools
    class MetsFile

      # Base class for a DNX section in the METS file. Each {DnxSection} derived class has a unique tag which will
      # become the id of the <section> element.
      class DnxSection < OpenStruct

        # Instance method to access the class tag for DNX.
        def tag
          _tag = self.class.name.split('::').last
          _tag[0] = _tag[0].downcase
          _tag
        end
      end

      # Specialized DNX section.
      class ObjectCharacteristics < DnxSection; end
      # Specialized DNX section.
      class GeneralIECharacteristics < DnxSection; end
      # Specialized DNX section.
      class GeneralRepCharacteristics < DnxSection; end
      # Specialized DNX section.
      class GeneralFileCharacteristics < DnxSection; end
      # Specialized DNX section.
      class RetentionPolicy < DnxSection; end
      # Specialized DNX section.
      class FileFixity < DnxSection; end
      # Specialized DNX section.
      class AccessRightsPolicy < DnxSection; end
      # Specialized DNX section.
      class WebHarvesting < DnxSection; end
      # Specialized DNX section.
      class Collection < DnxSection
        def tag; 'Collection'; end
      end
      # Specialized DNX section.
      class PreservationLevel < DnxSection; end
      # Specialized DNX section.
      class EnvironmentDependencies < DnxSection; end
      # Specialized DNX section.
      class EnvHardwareRegistry < DnxSection; end
      # Specialized DNX section.
      class EnvSoftwareRegistry < DnxSection; end
      # Specialized DNX section.
      class EnvironmentHardware < DnxSection; end
      # Specialized DNX section.
      class EnvironmentSoftware < DnxSection; end
      # Specialized DNX section.
      class Relationship < DnxSection; end
      # Specialized DNX section.
      class Environment < DnxSection; end
      # Specialized DNX section.
      class Inhibitors < DnxSection; end
      # Specialized DNX section.
      class SignatureInformation < DnxSection; end
      # Specialized DNX section.
      class CreatingApplication < DnxSection; end

    end
  end
end

