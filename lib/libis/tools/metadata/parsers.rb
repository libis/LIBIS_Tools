module Libis
  module Tools
    module Metadata

      autoload :BasicParser, 'libis/tools/metadata/parser/basic_parser'
      autoload :DublinCoreParser, 'libis/tools/metadata/parser/dublin_core_parser'
      autoload :Marc21Parser, 'libis/tools/metadata/parser/marc21_parser'
      autoload :SubfieldCriteriaParser, 'libis/tools/metadata/parser/subfield_criteria_parser'

    end
  end
end
