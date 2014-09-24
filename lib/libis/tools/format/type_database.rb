# coding: utf-8

require 'singleton'

module LIBIS
  module Tools
    module Format

      class TypeDatabase
        include Singleton

        def self.type2media(t)
          self.instance.type2media_map[t]
        end

        def self.type2mime(t)
          self.instance.type2mime_map[t].first
        end

        def self.type2ext(t)
          self.instance.type2ext_map[t].first
        end

        def self.media2type(media)
          self.instance.type2media_map.select do |_, v|
            v == media
          end.keys
        end

        def self.mime2type(mime)
          self.instance.type2mime_map.each do |t, m|
            return t if m.include? mime
          end
          nil
        end

        def self.mime2media(mime)
          type2media(mime2type(mime))
        end

        def self.ext2type(ext)
          self.instance.type2ext_map.each do |k, v|
            return k if v.include? ext
          end
          nil
        end

        def self.known_mime?(mime)
          self.instance.type2mime_map.each do |t, m|
            return true if m.include? mime
          end
          false
        end

        attr_reader :type2media_map, :type2mime_map, :type2ext_map, :types

        private

        def initialize
          @type2media_map = {}
          @type2mime_map = {}
          @type2ext_map = {}
          @types = Set.new
          CONFIG.each do |media, type_info|
            type_info.each do |type, info|
              @types.add type
              @type2media_map[type] = media
              @type2mime_map[type] = info[:MIME].split(',')
              @type2ext_map[type] = info[:EXTENSIONS].split(',')
            end
          end
        end

        CONFIG = {

            # This lists all the types the converters know about along with the mime types and file extensions.
            # The first file extension in the list is the default one that will be used when a file of that type is created.
            # The mime types need to be unique. Some mime types need to be 'invented' like for instance for PDF/A. The MimeType
            # class should take care of that.
            # Preferably the file extensions are unique too. If not, the first matching entry in the list will be used when a
            # reverse lookup from extension to type identifier is performed. However, file extensions will typically not be used
            # to determine type identifier or mime types. So you should be fairly safe when the file extensions are not unique.

            IMAGE: {# Image types
                    TIFF: {
                        MIME: 'image/tiff',
                        EXTENSIONS: %w(tif tiff)
                    },
                    JPEG2000: {
                        MIME: 'image/jp2',
                        EXTENSIONS: 'jp2,jpg2'
                    },
                    JPEG: {
                        MIME: 'image/jpeg',
                        EXTENSIONS: 'jpg,jpe,jpeg'
                    },
                    PNG: {
                        MIME: 'image/png',
                        EXTENSIONS: 'png'
                    },
                    BMP: {
                        MIME: 'image/bmp,image/x-ms-bmp',
                        EXTENSIONS: 'bmp'
                    },
                    GIF: {
                        MIME: 'image/gif',
                        EXTENSIONS: 'gif'}
            },
            AUDIO: {# Audio types
                    WAV: {
                        MIME: 'audio/x-wav',
                        EXTENSIONS: 'wav'
                    },
                    MP3: {
                        MIME: 'audio/mpeg',
                        EXTENSIONS: 'mp3'
                    },
                    FLAC: {
                        MIME: 'audio/flac',
                        EXTENSIONS: 'flac'
                    },
                    OGG: {
                        MIME: 'audio/ogg',
                        EXTENSIONS: 'ogg'
                    }
            },
            VIDEO: {# Video types
                    MPEG: {
                        MIME: 'video/mpeg',
                        EXTENSIONS: 'mpg,mpeg,mpa,mpe,mpv2'
                    },
                    MPEG4: {
                        MIME: 'video/mp4',
                        EXTENSIONS: 'mp4,mpeg4'
                    },
                    MJPEG2000: {
                        MIME: 'video/jpeg2000',
                        EXTENSIONS: 'mjp2'
                    },
                    QUICKTIME: {
                        MIME: 'video/quicktime',
                        EXTENSIONS: 'qt,mov'
                    },
                    AVI: {
                        MIME: 'video/x-msvideo',
                        EXTENSIONS: 'avi'
                    },
                    OGGV: {
                        MIME: 'video/ogg',
                        EXTENSIONS: 'ogv'
                    },
                    WMV: {
                        MIME: 'video/x-ms-wmv',
                        EXTENSIONS: 'wmv'},
                    DV: {
                        MIME: 'video/dv',
                        EXTENSIONS: 'dv'
                    },
                    FLASH: {
                        MIME: 'video/x-flv',
                        EXTENSIONS: 'flv'
                    }
            },
            DOCUMENT: {# Office document types
                       TXT: {
                           MIME: 'text/plain',
                           EXTENSIONS: 'txt'
                       },
                       RTF: {
                           MIME: 'text/rtf,application/msword',
                           EXTENSIONS: 'rtf'
                       },
                       HTML: {
                           MIME: 'text/html',
                           EXTENSIONS: 'html, htm'
                       },
                       MSDOC: {
                           MIME: 'application/vnd.ms-word,application/msword',
                           EXTENSIONS: 'doc'
                       },
                       MSDOCX: {
                           PUID: 'fido-fmt/189.word',
                           MIME: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                           EXTENSIONS: 'docx'
                       },
                       MSXLS: {
                           MIME: 'application/vnd.ms-excel,application/msexcel',
                           EXTENSIONS: 'xls'
                       },
                       MSXLSX: {
                           PUID: 'fido-fmt/189.xl',
                           MIME: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                           EXTENSIONS: 'xslx'
                       },
                       MSPPT: {
                           MIME: 'application/vnd.ms-powerpoint,application/mspowerpoint',
                           EXTENSIONS: 'ppt'
                       },
                       MSPPTX: {
                           PUID: 'fido-fmt/189.ppt',
                           MIME: 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
                           EXTENSIONS: 'pptx'
                       },
                       PDF: {
                           MIME: 'application/pdf',
                           EXTENSIONS: 'pdf'
                       },
                       PDFA: {
                           PUID: 'fmt/95',
                           MIME: 'application/pdfa', # Note the invented mime type here. It requires implementation in the MimeType class.
                           EXTENSIONS: 'pdf'
                       },
                       WORDPERFECT: {
                           PUID: 'x-fmt/44',
                           MIME: 'application/vnd.wordperfect',
                           EXTENSIONS: 'wpd'
                       },
                       XML: {
                           MIME: 'text/xml',
                           EXTENSIONS: 'xml'
                       },
                       SHAREPOINT_MAP: {
                           MIME: 'text/xml/sharepoint_map',
                           EXTENSIONS: 'xml'
                       }
            },
            ARCHIVE: {# Archive types
                      EAD: {
                          MIME: 'archive/ead', # This is again an invented mime type. It's actually an XML ...
                          EXTENSIONS: 'ead,xml'
                      }
            }
        }

      end

    end
  end
end
