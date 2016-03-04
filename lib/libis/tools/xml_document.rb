# coding: utf-8

require 'nokogiri'
require 'gyoku'
require 'nori'

module Libis
  module Tools

    # noinspection RubyTooManyMethodsInspection

    # This class embodies most used features of Nokogiri, Nori and Gyoku in one convenience class. The Nokogiri document
    # is stored in the class variable 'document' and can be accessed and manipulated directly - if required.
    #
    # In the examples we assume the following XML code:
    #
    #     <?xml version="1.0" encoding="utf-8"?>
    #     <patron>
    #       <name>Harry Potter</name>
    #       <barcode library='Hogwarts Library'>1234567890</barcode>
    #       <access_level>student</access_level>
    #       <email>harry.potter@hogwarts.edu</email>
    #       <email>hpotter@JKRowling.com</email>
    #     </patron>
    class XmlDocument

      attr_accessor :document

      # Check if the embedded XML document is not present or invalid.
      def invalid?
        @document.nil? or !document.is_a?(::Nokogiri::XML::Document) or @document.root.nil?
      end

      # Check if the embedded XML document is present and valid
      def valid?
        !invalid?
      end

      # Create new XmlDocument instance.
      # The object will contain a new and emtpy Nokogiri XML Document.
      # The object will not be valid until a root node is added.
      # @param [String] encoding character encoding for the XML content; default value is 'utf-8'
      # @return [XmlDocument] new instance
      def initialize(encoding = 'utf-8')
        @document = Nokogiri::XML::Document.new
        @document.encoding = encoding
      end

      # Create a new instance initialized with the content of an XML file.
      # @param [String] file path to the XML file
      # @return [XmlDocument] new instance
      def self.open(file)
        doc = XmlDocument.new
        doc.document = Nokogiri::XML(File.open(file))
        doc
      end

      # Create a new instance initialized with an XML String.
      # @param [String] xml XML string
      # @return [XmlDocument] new instance
      def self.parse(xml)
        doc = XmlDocument.new
        doc.document = Nokogiri::XML.parse(xml)
        doc
      end

      # Create a new instance initialized with a Hash.
      # @note The Hash will be converted with Gyoku. See the Gyoku documentation for the Hash format requirements.
      # @param [Hash] hash the content
      # @param [Hash] options options passed to Gyoku upon parsing the Hash into XML
      # @return [XmlDocument] new instance
      def self.from_hash(hash, options = {})
        doc = XmlDocument.new
        doc.document = Nokogiri::XML(Gyoku.xml(hash, options))
        doc.document.encoding = 'utf-8'
        doc
      end

      # Save the XML Document to a given XML file.
      # @param [String] file name of the file to save to
      # @param [Integer] indent amount of space for indenting; default 2
      # @param [String] encoding character encoding; default 'utf-8'
      def save(file, indent = 2, encoding = 'utf-8')
        fd = File.open(file, 'w')
        @document.write_xml_to(fd, :indent => indent, :encoding => encoding)
        fd.close
      end

      # Export the XML Document to an XML string.
      # @param [Hash] options options passed to the underlying Nokogiri::XML::Document#to_xml; default is:
      #     !{indent: 2, encoding: 'utf-8'}
      # @return [String] a string
      def to_xml(options = {})
        options = {indent: 2, encoding: 'utf-8', save_with: Nokogiri::XML::Node::SaveOptions::DEFAULT_XML}.merge(options)
        @document.to_xml(options)
      end

      # Export the XML Document to a Hash.
      #
      # @note The hash is generated using the Nori gem. The options passed to this call are used to configure Nori in
      #       the constructor call. For content and syntax see the
      #       {http://www.rubydoc.info/gems/nori/2.6.0 Nori documentation}. Nori also uses an enhanced
      #       String class with an extra method #attributes that will return a Hash containing tag-value pairs for each
      #       attribute of the XML element.
      #
      # Example:
      #
      #     h = xml_doc.to_hash
      #     # => { "patron" =>
      #             { "name" => "Harry Potter",
      #               "barcode" => "1234567890",
      #               "access_level" => "student",
      #               "email" => ["harry.potter@hogwarts.edu", "hpotter@JKRowling.com"],
      #          }  }
      #     h['patron']['barcode']
      #     # => "12345678890"
      #     h['patron']['barcode'].attributes
      #     # => {"library" => "Hogwarts Library"}
      #     h['patron']['barcode'].attributes['library']
      #     # => "Hogwarts Library"
      #
      # @param [Hash] options
      # @return [Hash]
      def to_hash(options = {})
        Nori.new(options).parse(to_xml)
      end

      # Check if the document validates against a given XML schema file.
      # @param [String] schema the file path of the XML schema
      # @return [Boolean]
      def validates_against?(schema)
        schema_doc = Nokogiri::XML::Schema.new(File.open(schema))
        schema_doc.valid?(@document)
      end

      # Check if the document validates against a given XML schema file.
      # @return [Array<{Nokogiri::XML::SyntaxError}>] a list of validation errors
      def validate(schema)
        schema_doc = Nokogiri::XML::Schema.new(File.open(schema))
        schema_doc.validate(@document)
      end

      # Add a processing instruction to the current XML document.
      # @note unlike regular nodes, these nodes are automatically added to the document.
      # @param [String] name instruction name
      # @param [String] content instruction content
      # @return [Nokogiri::XML::Node] the processing instruction node
      def add_processing_instruction(name, content)
        processing_instruction = Nokogiri::XML::ProcessingInstruction.new(@document, name, content)
        @document.root.add_previous_sibling processing_instruction
        processing_instruction
      end

      # Get the root node of the XML Document.
      #
      # Example:
      #
      #       puts xml_doc.root.to_xml
      #       # =>
      #           <patron>
      #             ...
      #           </patron>
      #
      # @return [{Nokogiri::XML::Node}] the root node of the XML Document
      def root
        raise ArgumentError, 'XML document not valid.' if @document.nil?
        @document.root
      end

      # Set the root node of the XML Document.
      #
      # Example:
      #
      #       patron = ::Nokogiri::XML::Node.new 'patron', xml_doc.document
      #       xml_doc.root = patron
      #       puts xml_doc.to_xml
      #       # =>
      #           <?xml version="1.0" encoding="utf-8"?>
      #           <patron/>
      #
      # @param [{Nokogiri::XML::Node}] node new root node
      # @return [{Nokogiri::XML::Node}] the new root node
      def root=(node)
        raise ArgumentError, 'XML document not valid.' if @document.nil?
        #noinspection RubyArgCount
        @document.root = node
      end

      # Creates nodes using the Nokogiri build short syntax.
      #
      # Example:
      #
      #     xml_doc.build(xml_doc.root) do |xml|
      #       xml.books do
      #         xml.book title: 'Quidditch Through the Ages', author: 'Kennilworthy Whisp', due_date: '1992-4-23'
      #       end
      #     end
      #     p xml_doc.to_xml
      #     # =>
      #           <?xml version="1.0" encoding="utf-8"?>
      #           <patron>
      #               ...
      #               <books>
      #                 <book title="Quidditch Through the Ages" author="Kennilworthy Whisp" due_date="1992-4-23"/>
      #               </books>
      #           </patron>
      #
      # @param [Nokogiri::XML::Node] at_node the node to attach the new nodes to;
      #     optional - if missing or nil the new nodes will replace the entire document
      # @param [Code block] block Build instructions
      # @return [XmlDocument] the XML Document itself
      def build(at_node = nil, options = {}, &block)
        options = {encoding: 'utf-8' }.merge options
        if at_node
            Nokogiri::XML::Builder.new(options,at_node, &block)
        else
          xml = Nokogiri::XML::Builder.new(options, &block)
          @document = xml.doc
        end
        self
      end

      # Creates a new XML document with contents supplied in Nokogiri build short syntax.
      #
      # Example:
      #
      #     xml_doc = ::Libis::Tools::XmlDocument.build do
      #       patron {
      #         name 'Harry Potter'
      #         barcode( '1234567890', library: 'Hogwarts Library')
      #         access_level 'student'
      #         email 'harry.potter@hogwarts.edu'
      #         email 'hpotter@JKRowling.com'
      #         books {
      #           book title: 'Quidditch Through the Ages', author: 'Kennilworthy Whisp', due_date: '1992-4-23'
      #         }
      #       }
      #     end
      #     p xml_doc.to_xml
      #     # =>
      #           <?xml version="1.0" encoding="utf-8"?>
      #               <patron>
      #           <name>Harry Potter</name>
      #             <barcode library="Hogwarts Library">1234567890</barcode>
      #           <access_level>student</access_level>
      #             <email>harry.potter@hogwarts.edu</email>
      #           <email>hpotter@JKRowling.com</email>
      #             <books>
      #               <book title="Quidditch Through the Ages" author="Kennilworthy Whisp" due_date="1992-4-23"/>
      #           </books>
      #           </patron>
      #
      # @param [Code block] block Build instructions
      # @return [XmlDocument] the new XML Document
      def self.build(&block)
        self.new.build(nil, &block)
      end

      # Adds a new XML node to the document.
      #
      # Example:
      #
      #       xml_doc = ::Libis::Tools::XmlDocument.new
      #       xml_doc.valid? # => false
      #       xml_doc.add_node :patron
      #       xml_doc.add_node :name, 'Harry Potter'
      #       books = xml_doc.add_node :books, nil, nil, namespaces: { jkr: 'http://JKRowling.com', node_ns: 'jkr' }
      #       xml_doc.add_node :book, nil, books,
      #           title: 'Quidditch Through the Ages', author: 'Kennilworthy Whisp', due_date: '1992-4-23',
      #           namespaces: { node_ns: 'jkr' }
      #       p xml_doc.to_xml
      #       # =>
      #           <?xml version="1.0" encoding="utf-8"?>
      #           <patron>
      #               <name>Harry Potter</name>
      #               <jkr:books xmlns:jkr="http://JKRowling.com">
      #                 <jkr:book author="Kennilworthy Whisp" due_date="1992-4-23" title="Quidditch Through the Ages"/>
      #               </jkr:books>
      #           </patron>
      #
      # @param [Array] args arguments being:
      #     - tag for the new node
      #     - optional content for new node; empty if nil or not present
      #     - optional parent node for new node; root if nil or not present; xml document if root is not defined
      #     - a Hash containing tag-value pairs for each attribute; the special key ':namespaces'
      #       contains a Hash of namespace definitions as in {#add_namespaces}
      # @return [Nokogiri::XML::Node] the new node
      def add_node(*args)
        attributes = {}
        attributes = args.pop if args.last.is_a? Hash
        name, value, parent = *args

        return nil if name.nil?

        node = Nokogiri::XML::Node.new name.to_s, @document
        node.content = value

        if !parent.nil?
          parent << node
        elsif !self.root.nil?
          self.root << node
        else
          self.root = node
        end

        return node if attributes.empty?

        namespaces = attributes.delete :namespaces
        add_namespaces(node, namespaces) if namespaces

        add_attributes(node, attributes) if attributes

        node

      end

      # Add attributes to a node.
      # @note The Nokogiri method Node#[]= is probably easier to use if you only want to add a single attribute ;the
      #     main purpose of this method is to make it easier to add attributes in bulk or if you have them already
      #     available as a Hash
      #
      # Example:
      #
      #       xml_doc.add_attributes xml_doc.root, status: 'active', id: '123456'
      #       xml_doc.to_xml
      #       # =>
      #           <?xml version="1.0" encoding="utf-8"?>
      #           <patron id="123456" status="active">
      #               ...
      #           </patron>
      #
      # @param [Nokogiri::XML::Node] node node to add the attributes to
      # @param [Hash] attributes a Hash with tag - value pairs for each attribute
      # @return [Nokogiri::XML::Node] the node
      def add_attributes(node, attributes)
        XmlDocument.add_attributes node, attributes
      end

      # (see #add_attributes)
      def self.add_attributes(node, attributes)

        attributes.each do |name, value|
          node.set_attribute name.to_s, value
        end

        node

      end

      # Add namespace information to a node
      #
      # Example:
      #
      #       xml_doc.add_namespaces xml_doc.root, jkr: 'http://JKRowling.com', node_ns: 'jkr'
      #       xml_doc.to_xml
      #       # =>
      #           <?xml version="1.0" encoding="utf-8"?>
      #           <jkr:patron xmlns:jkr="http://JKRowling.com">
      #               ...
      #           </jkr:patron>
      #
      #       xml_doc.add_namespaces xml_doc.root, nil => 'http://JKRowling.com'
      #       xml_doc.to_xml
      #       # =>
      #           <?xml version="1.0" encoding="utf-8"?>
      #           <patron xmlns="http://JKRowling.com">
      #               ...
      #           </patron>
      #
      # @param [Nokogiri::XML::Node] node the node where the namespace info should be added to
      # @param [Hash] namespaces a Hash with prefix - URI pairs for each namespace definition that should be added. The
      #     special key +:node_ns+ is reserved for specifying the prefix for the node itself. To set the default
      #     namespace, use the prefix +nil+
      def add_namespaces(node, namespaces)
        XmlDocument.add_namespaces node, namespaces
      end

      # (see #add_namespaces)
      def self.add_namespaces(node, namespaces)

        node_ns = namespaces.delete :node_ns
        default_ns = namespaces.delete nil

        namespaces.each do |prefix, prefix_uri|
          node.add_namespace prefix.to_s, prefix_uri
        end

        node.namespace_scopes.each do |ns|
          node.namespace = ns if ns.prefix == node_ns.to_s
        end if node_ns

        node.default_namespace = default_ns if default_ns

        node

      end

      # Search for nodes in the current document root.
      #
      # Example:
      #
      #       nodes = xml_doc.xpath('//email')
      #       nodes.size # => 2
      #       nodes.map(&:content) # => ["harry.potter@hogwarts.edu", "hpotter@JKRowling.com"]
      #
      # @param [String] path XPath search string
      # @return [{Nokogiri::XML::NodeSet}] set of nodes found
      def xpath(path)
        raise ArgumentError, 'XML document not valid.' if self.invalid?
        @document.xpath(path.to_s)
      end

      # Check if the XML document contains certain element(s) anywhere in the XML document.
      #
      # Example:
      #
      #       xml_doc.has_element? 'barcode[@library="Hogwarts Library"]' # => true
      #
      # @param [String] element_name name of the element(s) to search
      # @return [Integer] number of elements found
      def has_element?(element_name)
        list = xpath("//#{element_name}")
        list.nil? ? 0 : list.size
      end

      # Return the content of the first element found.
      #
      # Example:
      #
      #       xml_doc.value('//email') # => "harry.potter@hogwarts.edu"
      #
      # @param [String] path the name or XPath term to search the node(s)
      # @param [Node] parent parent node; document if nil
      # @return [String] content or nil if not found
      def value(path, parent = nil)
        parent ||= document
        parent.xpath(path).first.content rescue nil
      end

      # Return the content of the first element found.
      #
      # Example:
      #
      #       xml_doc['email'] # => "harry.potter@hogwarts.edu"
      #
      # @param [String] path the name or XPath term to search the node(s)
      # @return [String] content or nil if not found
      def [](path)
        xpath(path).first.content rescue nil
      end

      # Return the content of all elements found.
      # Example:
      #
      #       xml_doc.values('//email') # => [ "harry.potter@hogwarts.edu", "hpotter@JKRowling.com" ]
      #
      # @param (see #value)
      # @return [Array<String>] content
      def values(path)
        xpath(path).map &:content
      end

      # Return the content of the first element in the set of nodes.
      #
      # Example:
      #
      #       ::Libis::Tools::XmlDocument.get_content(xml_doc.xpath('//email')) # => "harry.potter@hogwarts.edu"
      #
      # @param [{Nokogiri::XML::NodeSet}] nodelist set of nodes to get content from
      # @return [String] content of the first node; always returns at least an empty string
      def self.get_content(nodelist)
        (nodelist.first && nodelist.first.content) || ''
      end

      # Find a node and set its content.
      #
      # Example:
      #
      #     xml_doc['//access_level'] = 'postgraduate'
      #     p xml_doc.to_xml
      #     # =>
      #           <?xml version="1.0" encoding="utf-8"?>
      #           <patron>
      #             ...
      #             <access_level>postgraduate</access_level>
      #             ...
      #           </patron>
      #
      # @param (see #value)
      # @param [String] value the content
      # @return [String] the value
      def []=(path, value)
        begin
          nodes = xpath(path)
          nodes.first.content = value
        rescue
          # ignored
        end
      end

      # Node access by method name.
      #
      # Nodes can be accessed through a method with signature the tag name of the node. There are several ways to use
      # this shorthand method:
      #
      #  * without arguments it simply returns the first node found
      #  * with one argument it retrieves the node's attribute
      #  * with one argument and '=' sign it sets the content of the node
      #  * with two arguments it sets the value of the node's attribute
      #  * with a code block it implements the build pattern
      #
      #
      #  Examples:
      #
      #       xml_doc.email
      #       # => "harry.potter@hogwarts.edu"
      #       p xml_doc.barcode 'library'
      #       # => "Hogwarts Library"
      #       xml_doc.access_level = 'postgraduate'
      #       xml_doc.barcode 'library', 'Hogwarts Dumbledore Library'
      #       xml_doc.dates do |dates|
      #         dates.birth_date '1980-07-31'
      #         dates.member_since '1991-09-01'
      #       end
      #       p xml_doc.to_xml
      #       # =>  <patron>
      #                 ...
      #                 <barcode library='Hogwarts Dumbledore Library'>1234567890</barcode>
      #                 <access_level>postgraduate</access_level>
      #                 ...
      #                 <dates>
      #                   <birth_date>1980-07-31</birth_date>
      #                   <member_since>1991-09-01</member_since>
      #                 </dates>
      #             </patron>
      #
      #
      def method_missing(method, *args, &block)
        super unless method.to_s =~ /^([a-z_][a-z_0-9]*)(!|=)?$/i
        node = get_node($1)
        node = add_node($1) if node.nil? || $2 == '!'
        case args.size
          when 0
            if block_given?
              build(node, &block)
            end
          when 1
            if $2.blank?
              return node[args.first.to_s]
            else
              node.content = args.first.to_s
            end
          when 2
            node[args.first.to_s] = args[1].to_s
            return node[args.first.to_s]
          else
            raise ArgumentError, 'Too many arguments.'
        end
        node
      end

      # Get the first node matching the tag. The node will be seached with XPath search term = "//#!{tag}".
      #
      # @param [String] tag XML tag to look for; XPath syntax is allowed
      # @param [Node] parent
      def get_node(tag, parent = nil)
        get_nodes(tag, parent).first
      end

      # Get all the nodes matching the tag. The node will be seached with XPath search term = "//#!{tag}".
      #
      # @param [String] tag XML tag to look for; XPath syntax is allowed
      # @param [Node] parent
      def get_nodes(tag, parent = nil)
        parent ||= root
        term = "#{tag.to_s =~ /^\// ? '' : '//'}#{tag.to_s}"
        parent.xpath(term)
      end

    end

  end
end
