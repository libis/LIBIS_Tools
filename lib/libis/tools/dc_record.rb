# encoding: utf-8

require_relative 'xml_document'

module Libis
  module Tools

    class DCRecord < XmlDocument

      # noinspection RubyResolve
      def initialize(doc = nil)
        super('utf-8')
        case doc
          when NilClass
            build do |xml|
              xml[:dc].record('xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                         'xmlns:dc' => 'http://purl.org/dc/elements/1.1/',
                         'xmlns:dcterms' => 'http://purl.org/dc/terms/') {
                yield xml if block_given?
              }
            end
          when ::Libis::Tools::XmlDocument
            @document = doc.document.dup
          when String
            if File.exist?(doc)
              # noinspection RubyResolve
              load(doc)
            else
              parse(doc)
            end
          when Hash
            self.from_hash(doc)
          when IO
            self.parse(doc.read)
          else
            raise ArgumentError, "Invalid argument: #{doc.inspect}"
        end
      end

      def add(tag, value = nil, attributes = {})
        add_node(tag, value, root, attributes)
      end

    end

  end
end
