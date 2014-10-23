# coding: utf-8

require 'nokogiri'
require 'gyoku'
require 'nori'

module LIBIS
  module Tools

    # noinspection RubyTooManyMethodsInspection
    class XmlDocument

      attr_accessor :document

      def invalid?
        @document.nil? or @document.root.nil?
      end

      def valid?
        ! invalid?
      end

      def initialize( encoding = 'utf-8')
        @document = Nokogiri::XML::Document.new
        @document.encoding = encoding
      end

      def self.open( file )
        doc = XmlDocument.new
        doc.document = Nokogiri::XML(File.open(file))
        doc
      end

      def self.parse( xml )
        doc = XmlDocument.new
        doc.document = Nokogiri::parse(xml)
        doc
      end

      def self.from_hash( hash, options = {} )
        doc = XmlDocument.new
        doc.document = Nokogiri::XML(Gyoku.xml(hash, options))
      end

      def save( file, indent = 2, encoding = 'utf-8' )
        fd = File.open(file, 'w')
        @document.write_xml_to(fd, :indent => indent, :encoding => encoding)
        fd.close
      end

      def to_xml( options = {} )
        options = { indent: 2, encoding: 'utf-8' }.merge(options)
        @document.to_xml(options)
      end

      def to_hash( options = {} )
        Nori.new(options).parse(to_xml)
      end

      def validates_against?(schema)
        schema_doc = Nokogiri::XML::Schema.new(File.open(schema))
        schema_doc.valid?(@document)
      end

      def validate(schema)
        schema_doc = Nokogiri::XML::Schema.new(File.open(schema))
        schema_doc.validate(@document)
      end

      def add_processing_instruction( name, content )
        processing_instruction = Nokogiri::XML::ProcessingInstruction.new( @document, name, content )
        @document.root.add_previous_sibling processing_instruction
        processing_instruction
      end

      def build( at_node = nil, &block )
        if at_node
          Nokogiri::XML::Builder.with(at_node, &block)
        else
          xml = Nokogiri::XML::Builder.new(&block)
          @document = xml.doc
        end
        self
      end

      def self.build(&block)
        self.new.build(nil, &block)
      end

      def create_text_node( name, text, options = {} )
        node = create_node name, options
        node << text
        node
      end

      def create_node( name, options = {} )

        node = Nokogiri::XML::Node.new name, @document

        return node if options.empty?

        namespaces = options.delete :namespaces
        add_namespaces( node, namespaces ) if namespaces

        attributes = options.delete :attributes
        add_attributes( node, attributes ) if attributes

        node

      end

      def add_namespaces( node, namespaces )
        XmlDocument.add_namespaces node, namespaces
      end

      def self.add_namespaces( node, namespaces )

        node_ns = namespaces.delete :node_ns

        namespaces.each do |prefix, prefix_uri|
          node.add_namespace prefix, prefix_uri
        end

        node.name = node_ns + ':' + node.name if node_ns

        node

      end

      def add_attributes( node, attributes )
        XmlDocument.add_attributes node, attributes
      end

      def self.add_attributes( node, attributes )

        attributes.each do |name, value|
          node.set_attribute name.to_s, value
        end

        node

      end

      def root=( node )
        raise ArgumentError, 'XML document not valid.' if @document.nil?
        #noinspection RubyArgCount
        @document.root = node
      end

      def root
        raise ArgumentError, 'XML document not valid.' if @document.nil?
        @document.root
      end

      def xpath(path)
        raise ArgumentError, 'XML document not valid.' if self.invalid?
        @document.xpath(path)
      end

      def has_element?(element_name)
        list = xpath("//#{element_name}")
        list.nil? ? 0 : list.size
      end

      def self.get_content(nodelist)
        (nodelist.first && nodelist.first.content) || ''
      end

      def value(key)
        get_node(key).content rescue nil
      end

      alias_method :[], :value

      def values(key)
        get_nodes(key).map &:content
      end

      def []=(key, value)
        node = get_node(key) || add_node(key, value)
        node.content = value if value
        node
      end

      def <<(*args)
        attributes = {}
        attributes = args.pop if args.last === Hash
        raise ArgumentError unless args.size == 2
        node = (self[args.first] = args.second)
        attributes.each {|k,v| node[k] = v}
      end

      def method_missing(method, *args, &block)
        super unless method.to_s =~ /^([a-z_][a-z0-9_]*)(=)?$/i
        node = get_node($1)
        super unless node
        case args.size
          when 0
            node = get_node($1)
            if block_given?
              build(node, &block)
            end
          when 1
            if $2
              node.content = args.first.to_s
            else
              return node[args.first.to_s]
            end
          when 2
            node[args.first.to_s] = args[1].to_s
            return node[args.first.to_s]
          else
            raise ArgumentError, 'Too many arguments.'
        end
        node
      end

      protected

      # Get all the first node matching the tag. The node will be seached with XPath search term = "//#{tag}".
      #
      # @param [String] tag XML tag to look for; XPath syntax is allowed
      # @param [Node] parent
      def get_node(tag, parent = nil)
        get_nodes(tag, parent).first
      end

      # Get all the nodes matching the tag. The node will be seached with XPath search term = "//#{tag}".
      #
      # @param [String] tag XML tag to look for; XPath syntax is allowed
      # @param [Node] parent
      def get_nodes(tag, parent = nil)
        parent ||= root
        term = "#{tag.to_s =~ /^\// ? '' : '//'}#{tag.to_s}"
        parent.xpath(term)
      end

      # Create a new node.
      #
      # @param [String] tag tag for the new node
      # @param [String] value optional content for new node; empty if nil
      # @param [Node] parent optional parent node for new node; root if nil
      # @param [Hash] attributes optional list of tag-value pairs for attributes to set on the new node
      def add_node(tag, value = nil, parent = nil, attributes = {})
        parent ||= root
        new_node = value.nil? ? create_node(tag) : create_text_node(tag, value)
        parent << new_node
        attributes.each { |k,v| new_node[k] = v }
        new_node
      end

    end

  end
end
