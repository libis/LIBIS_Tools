module LIBIS
  module Tools

    autoload :Checksum, 'libis/tools/checksum'
    autoload :Command, 'libis/tools/command'
    autoload :Config, 'libis/tools/config'
    autoload :DCRecord, 'libis/tools/dc_record'
    autoload :Logger, 'libis/tools/logger'
    autoload :MetsFile, 'libis/tools/mets_file'
    autoload :Parameter, 'libis/tools/parameter'
    autoload :XmlDocument, 'libis/tools/xml_document'

  end
end

require_relative 'tools/extend/struct'
