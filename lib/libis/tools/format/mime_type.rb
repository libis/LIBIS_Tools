# encoding: utf-8
require 'singleton'

module LIBIS
  module Tools
    module Format
      class MimeType
        include Singleton

        protected
        attr_reader :puid2mime

        def initialize
          @puid2mime = {}
          init
        end

        public
        def init
          @puid2mime['fido-fmt/189.word'] = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          @puid2mime['lias-fmt/189.word'] = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          @puid2mime['fido-fmt/189.xl'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
          @puid2mime['fido-fmt/189.ppt'] = 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
          @puid2mime['x-fmt/44'] = 'application/vnd.wordperfect'
          @puid2mime['x-fmt/394'] = 'application/vnd.wordperfect'
          @puid2mime['fmt/95'] = 'application/pdfa'
          @puid2mime['fmt/354'] = 'application/pdfa'
        end

        def self.puid_to_mime(puid)
          instance.puid2mime[puid] || 'None'
        end

        def self.add_puid(puid, mime)
          instance.puid2mime[puid] = mime
        end

      end
    end
  end
end
