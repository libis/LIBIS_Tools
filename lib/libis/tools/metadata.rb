module Libis
  module Tools
    module Metadata

      autoload :MarcRecord, 'libis/tools/metadata/marc_record'
      autoload :Marc21Record, 'libis/tools/metadata/marc21_record'
      autoload :DublinCoreRecord, 'libis/tools/metadata/dublin_core_record'

      module Mappers

        autoload :Kuleuven, 'libis/tools/metadata/mappers/kuleuven'
        autoload :Flandrica, 'libis/tools/metadata/mappers/flandrica'

      end

    end
  end
end

require_relative 'metadata/parsers'