# encoding: utf-8
require_relative 'spec_helper'
require 'libis/tools/xml_document'
require 'libis/tools/extend/string'

require 'rspec/matchers'
require 'equivalent-xml'

describe 'XML Document' do

  test_file = File.join(File.dirname(__FILE__), 'data', 'test.xml')
  test_xsd = File.join(File.dirname(__FILE__), 'test.xsd')

  def match_xml(doc1, doc2)
    doc1 = ::Nokogiri::XML(doc1) if doc1.is_a?(String)
    doc2 = ::Nokogiri::XML(doc2) if doc2.is_a?(String)
    # noinspection RubyResolve
    # expect(doc1).to be_equivalent_to(doc2).respecting_element_order
    expect(doc1).to be_equivalent_to(doc2)
  end

  before :context do
    @xml_template = <<-END.align_left
      <?xml version="1.0" encoding="utf-8"?>
      <patron>
        <name>Harry Potter</name>
        <barcode library="Hogwarts Library">1234567890</barcode>
        <access_level>student</access_level>
        <email>harry.potter@hogwarts.edu</email>
        <email>hpotter@JKRowling.com</email>
      </patron>
    END
  end

  it 'should create new empty XML document' do

    xml_doc = ::Libis::Tools::XmlDocument.new

    expect(xml_doc.document).not_to be_nil
    # noinspection RubyResolve
    expect(xml_doc).not_to be_valid
    # noinspection RubyResolve
    expect(xml_doc).to be_invalid

    match_xml xml_doc.document, <<-END.align_left
      <?xml version="1.0" encoding="utf-8"?>
    END

  end

  it 'should load test file' do
    xml_doc = ::Libis::Tools::XmlDocument.open(test_file)
    # noinspection RubyResolve
    expect(xml_doc).to be_valid
    match_xml xml_doc.document, @xml_template

  end

  it 'should parse XML from string' do
    xml_doc = ::Libis::Tools::XmlDocument.parse(<<-END.align_left)
      <patron>
        <name>Harry Potter</name>
        <barcode library="Hogwarts Library">1234567890</barcode>
        <access_level>student</access_level>
        <email>harry.potter@hogwarts.edu</email>
        <email>hpotter@JKRowling.com</email>
      </patron>
    END

    match_xml xml_doc.document, @xml_template
  end

  it 'should parse XML from Hash' do
    xml_doc = ::Libis::Tools::XmlDocument.from_hash({patron: {
                                                        name: 'Harry Potter',
                                                        barcode: {
                                                            '@library' => 'Hogwarts Library',
                                                            content!: '1234567890',
                                                        },
                                                        access_level: 'student',
                                                        email: %w'harry.potter@hogwarts.edu hpotter@JKRowling.com'
                                                    }},
                                                    {:key_converter => :none}
    )

    match_xml xml_doc.document, @xml_template

  end

  it 'should validate document against schema' do
    xml_doc = ::Libis::Tools::XmlDocument.open(test_file)

    expect(xml_doc.validates_against? test_xsd).to be_truthy
    # noinspection RubyResolve
    expect(xml_doc.validate test_xsd).to be_empty

  end

  it 'should allow to add a processing instruction' do
    xml_doc = ::Libis::Tools::XmlDocument.parse '<patron/>'
    xml_doc.add_processing_instruction 'xml-stylesheet', 'type="text/xsl" href="style.xsl"'

    match_xml xml_doc.document, <<-END.align_left
      <?xml version="1.0" encoding="utf-8"?>
      <?xml-stylesheet type="text/xsl" href="style.xsl"?>
      <patron/>
    END
  end

  it 'should get the root node of the document' do
    xml_doc = ::Libis::Tools::XmlDocument.open(test_file)
    root = xml_doc.root

    expect(root.name).to eq 'patron'
    match_xml root.document, <<-END.align_left
      <patron>
        <name>Harry Potter</name>
        <barcode library="Hogwarts Library">1234567890</barcode>
        <access_level>student</access_level>
        <email>harry.potter@hogwarts.edu</email>
        <email>hpotter@JKRowling.com</email>
      </patron>
    END

  end

  it 'should set the root node of the document' do
    xml_doc = ::Libis::Tools::XmlDocument.new
    patron = ::Nokogiri::XML::Node.new 'patron', xml_doc.document
    xml_doc.root = patron

    match_xml xml_doc.document, <<-END.align_left
      <?xml version="1.0" encoding="utf-8"?>
      <patron/>
    END

  end

  it 'should enable Nokogiri Build syntax' do
    xml_doc = ::Libis::Tools::XmlDocument.open(test_file)

    xml_doc.build(xml_doc.root) do
      # noinspection RubyResolve
      books do
        book title: 'Quidditch Through the Ages', author: 'Kennilworthy Whisp', due_date: '1992-4-23'
      end
    end

    match_xml xml_doc.document, <<-END.align_left
      <?xml version="1.0" encoding="utf-8"?>
      <patron>
        <name>Harry Potter</name>
        <barcode library="Hogwarts Library">1234567890</barcode>
        <access_level>student</access_level>
        <email>harry.potter@hogwarts.edu</email>
        <email>hpotter@JKRowling.com</email>
        <books>
          <book title="Quidditch Through the Ages" author="Kennilworthy Whisp" due_date="1992-4-23"/>
        </books>
      </patron>
    END

  end

  it 'should enable Nokogiri Build syntax for new document' do
    xml_doc = ::Libis::Tools::XmlDocument.build do
      # noinspection RubyResolve
      patron {
        name 'Harry Potter'
        barcode( '1234567890', library: 'Hogwarts Library')
        access_level 'student'
        email 'harry.potter@hogwarts.edu'
        email 'hpotter@JKRowling.com'
        # noinspection RubyResolve
        books {
          book title: 'Quidditch Through the Ages', author: 'Kennilworthy Whisp', due_date: '1992-4-23'
        }
      }
    end

    match_xml xml_doc.document, <<-END.align_left
      <?xml version="1.0" encoding="utf-8"?>
      <patron>
        <name>Harry Potter</name>
        <barcode library="Hogwarts Library">1234567890</barcode>
        <access_level>student</access_level>
        <email>harry.potter@hogwarts.edu</email>
        <email>hpotter@JKRowling.com</email>
        <books>
          <book title="Quidditch Through the Ages" author="Kennilworthy Whisp" due_date="1992-4-23"/>
        </books>
      </patron>
    END

  end

  it 'should add a new node to the document' do
    xml_doc = ::Libis::Tools::XmlDocument.new

    xml_doc.add_node :patron
    xml_doc.add_node :name, 'Harry Potter'
    books = xml_doc.add_node :books, nil, nil, namespaces: { jkr: 'http://JKRowling.com' , node_ns: 'jkr' }
    xml_doc.add_node :book, nil, books,
                     title: 'Quidditch Through the Ages', author: 'Kennilworthy Whisp', due_date: '1992-4-23',
                     namespaces: {node_ns: 'jkr'}

    match_xml xml_doc.document, <<-END.align_left
      <?xml version="1.0" encoding="utf-8"?>
      <patron>
        <name>Harry Potter</name>
        <jkr:books xmlns:jkr="http://JKRowling.com">
          <jkr:book author="Kennilworthy Whisp" due_date="1992-4-23" title="Quidditch Through the Ages"/>
        </jkr:books>
      </patron>
    END

    expect(xml_doc.root.name).to eq 'patron'
    expect(xml_doc.root.children.size).to be 2
    expect(xml_doc.root.children[0].name).to eq 'name'
    expect(xml_doc.root.children[0].content).to eq 'Harry Potter'
    expect(xml_doc.root.children[1].name).to eq 'books'
    expect(xml_doc.root.children[1].namespace.prefix).to eq 'jkr'
    expect(xml_doc.root.children[1].namespace.href).to eq 'http://JKRowling.com'
    expect(xml_doc.root.children[1].namespaces.size).to be 1
    expect(xml_doc.root.children[1].namespaces['xmlns:jkr']).to eq 'http://JKRowling.com'
    expect(xml_doc.root.children[1].children.size).to be 1
    expect(xml_doc.root.children[1].children[0].name).to eq 'book'
    expect(xml_doc.root.children[1].children[0].namespace.prefix).to eq 'jkr'
    expect(xml_doc.root.children[1].children[0].namespace.href).to eq 'http://JKRowling.com'
    expect(xml_doc.root.children[1].children[0]['title']).to eq 'Quidditch Through the Ages'
    expect(xml_doc.root.children[1].children[0]['author']).to eq 'Kennilworthy Whisp'
    expect(xml_doc.root.children[1].children[0]['due_date']).to eq '1992-4-23'

  end

  it 'should add attributes to a node' do
    xml_doc = ::Libis::Tools::XmlDocument.open(test_file)

    xml_doc.add_attributes xml_doc.root, id: '123456', status: 'active'

    match_xml xml_doc.document, <<-END.align_left
      <?xml version="1.0" encoding="utf-8"?>
      <patron status="active" id="123456">
        <name>Harry Potter</name>
        <barcode library="Hogwarts Library">1234567890</barcode>
        <access_level>student</access_level>
        <email>harry.potter@hogwarts.edu</email>
        <email>hpotter@JKRowling.com</email>
      </patron>
    END

  end

  it 'should add namespaces to a node' do
    xml_doc = ::Libis::Tools::XmlDocument.open(test_file)

    xml_doc.add_namespaces xml_doc.root, jkr: 'http://JKRowling.com', node_ns: 'jkr'
    # noinspection RubyResolve
    xml_doc.add_namespaces xml_doc.barcode, nil => 'http://hogwarts.edu'

    match_xml xml_doc.document, <<-END.align_left
      <?xml version="1.0" encoding="utf-8"?>
      <jkr:patron xmlns:jkr="http://JKRowling.com">
        <name>Harry Potter</name>
        <barcode library="Hogwarts Library" xmlns="http://hogwarts.edu">1234567890</barcode>
        <access_level>student</access_level>
        <email>harry.potter@hogwarts.edu</email>
        <email>hpotter@JKRowling.com</email>
      </jkr:patron>
    END

    expect(xml_doc.document.root.namespace.prefix).to eq 'jkr'
    expect(xml_doc.document.root.namespace.href).to eq 'http://JKRowling.com'
    expect(xml_doc.document.root.elements[1].namespace.prefix).to be_nil
    expect(xml_doc.document.root.elements[1].namespace.href).to eq 'http://hogwarts.edu'

  end

  it 'should search for nodes in the current document root' do
    xml_doc = ::Libis::Tools::XmlDocument.open(test_file)

    nodes = xml_doc.xpath('//email')
    expect(nodes.size).to be 2
    expect(nodes.map(&:content)).to eq %w'harry.potter@hogwarts.edu hpotter@JKRowling.com'

  end

  it 'should check if the XML document contains certain element(s)' do
    xml_doc = ::Libis::Tools::XmlDocument.open(test_file)

    expect(xml_doc.has_element? 'barcode[@library="Hogwarts Library"]').to be_truthy

  end

  it 'should return the content of the first element found' do
    xml_doc = ::Libis::Tools::XmlDocument.open(test_file)

    expect(xml_doc.value('//email')).to eq 'harry.potter@hogwarts.edu'

  end

  it 'should return the content of all elements found' do
    xml_doc = ::Libis::Tools::XmlDocument.open(test_file)

    expect(xml_doc.values('//email')).to eq %w'harry.potter@hogwarts.edu hpotter@JKRowling.com'

  end

  it 'should return the content of the first element in the set of nodes' do
    xml_doc = ::Libis::Tools::XmlDocument.open(test_file)

    expect(::Libis::Tools::XmlDocument.get_content(xml_doc.xpath('//email'))).to eq 'harry.potter@hogwarts.edu'
  end

  it 'should Find a node and set its content' do
    xml_doc = ::Libis::Tools::XmlDocument.open(test_file)

    xml_doc['//access_level'] = 'postgraduate'

    match_xml xml_doc.document, <<-END.align_left
      <?xml version="1.0" encoding="utf-8"?>
      <patron>
        <name>Harry Potter</name>
        <barcode library="Hogwarts Library">1234567890</barcode>
        <access_level>postgraduate</access_level>
        <email>harry.potter@hogwarts.edu</email>
        <email>hpotter@JKRowling.com</email>
      </patron>
    END

  end

  # noinspection RubyResolve
  it 'should allow node access by method name' do
    xml_doc = ::Libis::Tools::XmlDocument.open(test_file)

    expect(xml_doc.email.content).to eq 'harry.potter@hogwarts.edu'
    expect(xml_doc.barcode 'library').to eq 'Hogwarts Library'

    xml_doc.access_level = 'postgraduate'
    xml_doc.barcode 'library', 'Hogwarts Dumbledore Library'
    # noinspection RubyResolve
    xml_doc.dates do |dates|
      dates.birth_date '1980-07-31'
      dates.member_since '1991-09-01'
    end

    match_xml xml_doc.document, <<-END.align_left
      <?xml version="1.0" encoding="utf-8"?>
      <patron>
        <name>Harry Potter</name>
        <barcode library="Hogwarts Dumbledore Library">1234567890</barcode>
        <access_level>postgraduate</access_level>
        <email>harry.potter@hogwarts.edu</email>
        <email>hpotter@JKRowling.com</email>
        <dates>
          <birth_date>1980-07-31</birth_date>
          <member_since>1991-09-01</member_since>
        </dates>
      </patron>
    END

  end

  it 'should work' do
    xml_doc = ::Libis::Tools::XmlDocument.parse(<<-END.align_left)
      <patron>
        <name>Harry Potter</name>
        <barcode library="Hogwarts Library">1234567890</barcode>
        <access_level>student</access_level>
        <email>harry.potter@hogwarts.edu</email>
        <email>hpotter@JKRowling.com</email>
      </patron>
    END

    match_xml xml_doc.document, @xml_template

    xml_doc.save('/tmp/test.xml')

    xml_doc = ::Libis::Tools::XmlDocument.open('/tmp/test.xml')

    match_xml xml_doc.document, @xml_template

    xml_doc = ::Libis::Tools::XmlDocument.build do
      # noinspection RubyResolve
      patron {
        name 'Harry Potter'
        barcode( '1234567890', library: 'Hogwarts Library')
        access_level 'student'
        email 'harry.potter@hogwarts.edu'
        email 'hpotter@JKRowling.com'
      }
    end

    match_xml xml_doc.document, @xml_template

    xml_doc = ::Libis::Tools::XmlDocument.new
    xml_doc.add_node :patron
    xml_doc.name = 'Harry Potter'
    # noinspection RubyResolve
    xml_doc.barcode = '1234567890'
    # noinspection RubyResolve
    xml_doc.barcode :library, 'Hogwarts Library'
    # noinspection RubyResolve
    xml_doc.access_level = 'student'
    xml_doc.email = 'harry.potter@hogwarts.edu'
    xml_doc.add_node :email, 'hpotter@JKRowling.com'

    match_xml xml_doc.document, @xml_template

  end

end
