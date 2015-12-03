# encoding: utf-8
require 'nori'
require 'libis/tools/assert'

module Libis
  module Tools
    module Metadata

      class DublinCoreRecord < Libis::Tools::XmlDocument

        DC_ELEMENTS = %w'contributor coverage creator date description format identifier language' +
            %w'publisher relation rights source subject title type'
        DCTERMS_ELEMENTS = %w'abstract accessRights accrualMethod accrualPeriodicity accrualPolicy alternative' +
            %w'audience available bibliographicCitation conformsTo contributor coverage created creator date' +
            %w'dateAccepted dateCopyrighted dateSubmitted description educationLevel extent format hasFormat' +
            %w'hasPart hasVersion identifier instructionalMethod isFormatOf isPartOf isReferencedBy isReplacedBy' +
            %w'isRequiredBy issued isVersionOf language license mediator medium modified provenance publisher' +
            %w'references relation replaces requires rights rightsHolder source spatial subject tableOfContents' +
            %w'temporal title type valid'

        def initialize(doc = nil)
          super()
          xml_doc = case doc
                      when ::Libis::Tools::XmlDocument
                        doc
                      when String
                        # noinspection RubyResolve
                        File.exist?(doc) ? Libis::Tools::XmlDocument.load(doc) : Libis::Tools::XmlDocument.parse(doc)
                      when IO
                        Libis::Tools::XmlDocument.parse(doc.read)
                      when Hash
                        Libis::Tools::XmlDocument.from_hash(doc)
                      when NilClass
                        Libis::Tools::XmlDocument.new.build do |xml|
                          xml[:dc].record('xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                                     'xmlns:dc' => 'http://purl.org/dc/elements/1.1/',
                                     'xmlns:dcterms' => 'http://purl.org/dc/terms/') {
                            yield xml if block_given?
                          }
                        end
                      else
                        raise ArgumentError, "Invalid argument: #{doc.inspect}"
                    end
          @document = xml_doc.document if xml_doc
          raise ArgumentError, 'XML document not valid.' if self.invalid?
        end

        def all
          @all_records ||= get_all_records
        end

        def xpath(path)
          m = /^([\/.]*\/)?(dc(terms)?:)?(.*)/.match(path.to_s)
          return [] unless m[4]
          path = (m[1] || '') + ('dc:' || m[2]) + m[4]
          @document.xpath(path.to_s)
        end

        def add_node(name, value = nil, parent = nil, attributes = {})
          ns, tag = get_namespace(name.to_s)
          (attributes[:namespaces] ||= {})[:node_ns] ||= ns if ns
          super tag, value, parent, attributes
        end

        protected

        def get_nodes(tag, parent = nil)
          parent ||= root
          m = /^([\/\.]*\/)?(dc(?:terms)?:)?(.*)/.match(tag.to_s)
          return [] unless m[3]
          path = (m[1] || '')
          ns, tag = get_namespace(tag)
          path += "#{ns}:" if ns
          path += tag
          parent.xpath(path)
        end

        def get_namespace(tag)
          m = /^((dc)?(terms)?(?:_|:)?)?([a-zA-Z_][-_.0-9a-zA-Z]+)(.*)/.match tag
          ns = if m[1].blank?
                   if DC_ELEMENTS.include?(m[4])
                     :dc
                   else
                     DCTERMS_ELEMENTS.include?(m[4]) ? :dcterms : nil
                   end
               elsif m[3].blank?
                 :dc
               else
                 :dcterms
               end
          [ns, "#{m[4]}#{m[5]}"]
        end

      end

    end
  end
end
