module LIBIS
  module Tools

    autoload :Checksum, 'libis/tools/checksum'
    autoload :Command, 'libis/tools/command'
    autoload :Config, 'libis/tools/config'
    autoload :Converter, 'libis/tools/converter'
    autoload :DCRecord, 'libis/tools/dc_record'
    autoload :Logger, 'libis/tools/logger'
    autoload :MetsFile, 'libis/tools/mets_file'
    autoload :OracleClient, 'libis/tools/oracle_client'
    autoload :Parameter, 'libis/tools/parameter'
    autoload :XmlDocument, 'libis/tools/xml_document'

  end
end

require_relative 'tools/format'
require_relative 'tools/webservices'

require_relative 'tools/extend/http_fetch'
require_relative 'tools/extend/struct'
