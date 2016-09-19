# encoding: utf-8
require 'nori'
require 'libis/tools/assert'

module Libis
  module Tools
    module Metadata

      # Conveniece class to create and read DC records.
      # Most of the functionality is derived from the {::Libis::Tools::XmlDocument} base class. This class puts its
      # focus on supporting the <dc:xxx> and <dcterms:xxx> namespaces. For most tags the namespaces are added
      # automatically by checking which tag you want to add. In some cases the same tag exists in both namespaces and
      # you may want to state the namespace explicitely. Even then things are made as easily as possible.
      class DublinCoreRecord < Libis::Tools::XmlDocument

        # List of known tags in the DC namespace
        DC_ELEMENTS = %w'contributor coverage creator date description format identifier language' +
            %w'publisher relation rights source subject title type'
        # List of known tags in the DCTERMS namespace
        DCTERMS_ELEMENTS = %w'abstract accessRights accrualMethod accrualPeriodicity accrualPolicy alternative' +
            %w'audience available bibliographicCitation conformsTo contributor coverage created creator date' +
            %w'dateAccepted dateCopyrighted dateSubmitted description educationLevel extent format hasFormat' +
            %w'hasPart hasVersion identifier instructionalMethod isFormatOf isPartOf isReferencedBy isReplacedBy' +
            %w'isRequiredBy issued isVersionOf language license mediator medium modified provenance publisher' +
            %w'references relation replaces requires rights rightsHolder source spatial subject tableOfContents' +
            %w'temporal title type valid'

        # Create new DC document.
        # If the doc parameter is nil a new empty DC document will be created with the dc:record root element and all
        # required namespaces defined.
        # @note The input document is not checked if it is a valid DC record XML.
        # @param [::Libis::Tools::XmlDocument,String,IO,Hash] doc optional document to read.
        def initialize(doc = nil)
          super()
          xml_doc = case doc
                      when ::Libis::Tools::XmlDocument
                        doc
                      when String
                        # noinspection RubyResolve
                        File.exist?(doc) ? Libis::Tools::XmlDocument.open(doc) : Libis::Tools::XmlDocument.parse(doc)
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

        # Search the document with xpath.
        # If no namespace is present, the 'dc:' namespace will be added.
        # @param [String] path any valid XPath expression
        def xpath(path)
          m = /^([\/.]*\/)?(dc(terms)?:)?(.*)/.match(path.to_s)
          return [] unless m[4]
          path = (m[1] || '') + ('dc:' || m[2]) + m[4]
          @document.xpath(path.to_s)
        end

        # Add a node.
        # You can omit the namespace in the name parameter. The method will add the correct namespace for you. If using
        # symbols for name, an underscore ('_') can be used as separator instead of the colon (':').
        # @param [String,Symbol] name tag name of the element
        # @param [String] value content of the new element
        # @param [Nokogiri::XML::Node] parent the new element will be attached to this node
        # @param [Hash] attributes list of <attribute_name>, <attribute_value> pairs for the new element
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
