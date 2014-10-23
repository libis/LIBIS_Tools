# encoding: utf-8

require 'singleton'
require 'csv'

require 'libis/tools/logger'
require 'libis/tools/command'
require 'libis/tools/xml_document'

require 'libis/tools/extend/string'

require_relative 'mime_type'

module LIBIS
  module Tools
    module Format

      class Identifier
        include ::LIBIS::Tools::Logger
        include Singleton

        BAD_MIMETYPES = %w(None)
        RETRY_MIMETYPES = %w(application/rtf text/rtf) + BAD_MIMETYPES

        attr_reader :fido_formats
        attr_reader :xml_validations

        def initialize
          @fido_formats = [File.absolute_path(File.join(File.dirname(__FILE__),'lias_formats.xml'))]
          # noinspection RubyStringKeysInHashInspection
          @xml_validations = {'archive/ead' => 'config/ead.xsd'}
        end

        def self.add_fido_format(f)
          instance.fido_formats << f
        end

        def self.fido_formats
          instance.fido_formats
        end

        def self.add_xml_validation(mimetype, xsd_file)
          instance.xml_validations[mimetype] = xsd_file
        end

        def self.xml_validations
          instance.xml_validations
        end

        def self.get(file_path, options)

          fp = file_path.to_s.escape_for_string
          options ||= {}

          result = {}
          mimetype = nil

          formats = self.fido_formats.dup
          case options[:formats]
            when Array
              formats += options[:formats]
            when String
              formats << options[:formats]
            else
              # do nothing
          end

          # use FIDO
          cmd = 'fido'
          args = []
          args << '-loadformats' << "\"#{formats.join('","')}\"" unless formats.empty?
          args << "\"#{fp}\""
          fido = ::LIBIS::Tools::Command.run(cmd, *args)
          #info "Fido result: '#{fido[:out].to_s}'"
          fido_output = CSV.parse fido[:out]
          fido_result = nil
          while fido_output.size > 0
            x = fido_output.pop
            if x[0] == 'OK' && x[8] == 'signature'
              fido_result = x
              break
            end
          end
          if fido_result && fido_result[0] == 'OK'
            format = fido_result[2]
            mimetype = fido_result[7]
            mimetype = ::LIBIS::Tools::Format::MimeType.puid_to_mime(format) if mimetype == 'None'
            #info "Fido MIME-type: #{mimetype} (PRONOM UID: #{format})"
            result = {mimetype: mimetype, puid: format} unless BAD_MIMETYPES.include? mimetype
          end

          # use FILE
          if result[:mimetype].nil? or RETRY_MIMETYPES.include? mimetype
            mimetype = ::LIBIS::Tools::Command.run('file', '-ib', "\"#{fp}\"")[:out].strip.split(';')[0].split(',')[0]
            #info "File result: '#{mimetype}'"
            result = {mimetype: mimetype} unless BAD_MIMETYPES.include? mimetype
          end

          # determine XML type. Add custom types at runtime with
          # LIBIS::Tools::Format::Identifier.add_xml_validation('my_type', '/path/to/my_type.xsd')
          if result[:mimetype] == 'text/xml'
            doc = ::LIBIS::Tools::XmlDocument.open file_path
            xml_validations.each do |mime, xsd_file|
              result[:mimetype] = mime if doc.validates_against?(xsd_file)
            end
          end

          # use ImageMagik's identify to detect JPeg 2000 files
          if result.nil?
            begin
              x = ::LIBIS::Tools::Command.run('identify', '-format', '%m', "\"#{fp}\"")
              x = x[:out]
              info "Identify result: '#{x.to_s}'"
              x = x.split[0].strip if x
              result = 'image/jp2' if x == 'JP2'
            rescue Exception
              # ignored
            end
          end

          # result ? info("Final MIME-type: '#{result}'") : warn("Could not identify MIME type of '#{fp}'")

          result
        end

      end

    end
  end
end
