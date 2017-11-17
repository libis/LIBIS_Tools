require_relative 'tools/version'

module Libis
  module Tools

    autoload :Checksum, 'libis/tools/checksum'
    autoload :Command, 'libis/tools/command'
    autoload :Config, 'libis/tools/config'
    autoload :ConfigFile, 'libis/tools/config_file'
    autoload :Csv, 'libis/tools/csv'
    autoload :DeepStruct, 'libis/tools/deep_struct'
    autoload :Logger, 'libis/tools/logger'
    autoload :MetsFile, 'libis/tools/mets_file'
    autoload :Parameter, 'libis/tools/parameter'
    autoload :Spreadsheet, 'libis/tools/spreadsheet'
    autoload :TempFile, 'libis/tools/temp_file'
    autoload :ThreadSafe, 'libis/tools/thread_safe'
    autoload :XmlDocument, 'libis/tools/xml_document'

  end
end

require_relative 'tools/metadata'
require_relative 'tools/extend/struct'
