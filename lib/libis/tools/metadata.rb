module Libis
  module Tools

    # This module groups several metadata formats. Note that all metadata related classes will move into a Gem of their
    # own in the future.
    module Metadata

      autoload :MarcRecord, 'libis/tools/metadata/marc_record'
      autoload :Marc21Record, 'libis/tools/metadata/marc21_record'
      autoload :DublinCoreRecord, 'libis/tools/metadata/dublin_core_record'

      # Mappers implementations for converting MARC records to Dublin Core.
      module Mappers

        autoload :Kuleuven, 'libis/tools/metadata/mappers/kuleuven'
        autoload :Flandrica, 'libis/tools/metadata/mappers/flandrica'
        autoload :Scope, 'libis/tools/metadata/mappers/scope'

      end

    end
  end
end

require_relative 'metadata/parsers'
