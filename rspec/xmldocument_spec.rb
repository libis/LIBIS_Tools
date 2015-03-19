# encoding: utf-8
require_relative 'spec_helper'
require 'libis/tools/xml_document'
require 'libis/tools/extend/string'

describe 'XML Document' do

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

    xml_doc = ::LIBIS::Tools::XmlDocument.new

    expect(xml_doc.document).not_to be_nil
    # noinspection RubyResolve
    expect(xml_doc).not_to be_valid
    # noinspection RubyResolve
    expect(xml_doc).to be_invalid

    expect(xml_doc.to_xml).to eq <<-END.align_left
      <?xml version="1.0" encoding="utf-8"?>
    END

  end

  it 'should load test file' do
    xml_doc = ::LIBIS::Tools::XmlDocument.open('data/test.xml')
    # noinspection RubyResolve
    expect(xml_doc).to be_valid
    expect(xml_doc.to_xml).to eq @xml_template

  end

  it 'should parse XML from string' do
    xml_doc = ::LIBIS::Tools::XmlDocument.parse(<<-END.align_left)
      <patron>
        <name>Harry Potter</name>
        <barcode library="Hogwarts Library">1234567890</barcode>
        <access_level>student</access_level>
        <email>harry.potter@hogwarts.edu</email>
        <email>hpotter@JKRowling.com</email>
      </patron>
    END

    expect(xml_doc.to_xml).to eq @xml_template
  end

  it 'should parse XML from Hash' do
    xml_doc = ::LIBIS::Tools::XmlDocument.from_hash({patron: {
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

    expect(xml_doc.to_xml).to eq @xml_template

  end

  it 'should validate document against schema' do
    xml_doc = ::LIBIS::Tools::XmlDocument.open('data/test.xml')

    expect(xml_doc.validates_against? 'test.xsd').to be_truthy
    # noinspection RubyResolve
    expect(xml_doc.validate 'test.xsd').to be_empty

  end

  it 'should allow to add a processing instruction' do
    xml_doc = ::LIBIS::Tools::XmlDocument.parse '<patron/>'
    xml_doc.add_processing_instruction 'xml-stylesheet', 'type="text/xsl" href="style.xsl"'

    expect(xml_doc.to_xml).to eq(<<-END.align_left)
      <?xml version="1.0" encoding="utf-8"?>
      <?xml-stylesheet type="text/xsl" href="style.xsl"?>
      <patron/>
    END
  end

  it 'should get the root node of the document' do
    xml_doc = ::LIBIS::Tools::XmlDocument.open('data/test.xml')
    root = xml_doc.root

    expect(root.name).to eq 'patron'
    expect(root.to_xml).to eq(<<-END.align_left.chomp)
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
    xml_doc = ::LIBIS::Tools::XmlDocument.new
    patron = ::Nokogiri::XML::Node.new 'patron', xml_doc.document
    xml_doc.root = patron

    expect(xml_doc.to_xml).to eq(<<-END.align_left)
      <?xml version="1.0" encoding="utf-8"?>
      <patron/>
    END

  end

  it 'should enable Nokogiri Build syntax' do
    xml_doc = ::LIBIS::Tools::XmlDocument.open('data/test.xml')

    xml_doc.build(xml_doc.root) do
      # noinspection RubyResolve
      books do
        book title: 'Quidditch Through the Ages', author: 'Kennilworthy Whisp', due_date: '1992-4-23'
      end
    end

    expect(xml_doc.to_xml).to eq(<<-END.align_left)
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
    xml_doc = ::LIBIS::Tools::XmlDocument.build do
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

    expect(xml_doc.to_xml).to eq(<<-END.align_left)
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
    xml_doc = ::LIBIS::Tools::XmlDocument.new

    xml_doc.add_node :patron
    xml_doc.add_node :name, 'Harry Potter'
    books = xml_doc.add_node :books, nil, nil, namespaces: { jkr: 'http://JKRowling.com', node_ns: 'jkr' }
    xml_doc.add_node :book, nil, books,
                     title: 'Quidditch Through the Ages', author: 'Kennilworthy Whisp', due_date: '1992-4-23',
                     namespaces: { node_ns: 'jkr' }

    expect(xml_doc.to_xml).to eq(<<-END.align_left)
      <?xml version="1.0" encoding="utf-8"?>
      <patron>
        <name>Harry Potter</name>
        <jkr:books xmlns:jkr="http://JKRowling.com">
          <jkr:book title="Quidditch Through the Ages" author="Kennilworthy Whisp" due_date="1992-4-23"/>
        </jkr:books>
      </patron>
    END

    expect(xml_doc.root.name).to eq 'patron'
    expect(xml_doc.root.children.size).to be 2
    expect(xml_doc.root.children[0].name).to eq 'name'
    expect(xml_doc.root.children[0].content).to eq 'Harry Potter'
    expect(xml_doc.root.children[1].name).to eq 'jkr:books'
    expect(xml_doc.root.children[1].namespaces.size).to be 1
    expect(xml_doc.root.children[1].namespaces['xmlns:jkr']).to eq 'http://JKRowling.com'
    expect(xml_doc.root.children[1].children.size).to be 1
    expect(xml_doc.root.children[1].children[0].name).to eq 'jkr:book'
    expect(xml_doc.root.children[1].children[0]['title']).to eq 'Quidditch Through the Ages'
    expect(xml_doc.root.children[1].children[0]['author']).to eq 'Kennilworthy Whisp'
    expect(xml_doc.root.children[1].children[0]['due_date']).to eq '1992-4-23'

  end

  it 'should add attributes to a node' do
    xml_doc = ::LIBIS::Tools::XmlDocument.open('data/test.xml')

    xml_doc.add_attributes xml_doc.root, status: 'active', id: '123456'

    expect(xml_doc.to_xml).to eq(<<-END.align_left)
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
    xml_doc = ::LIBIS::Tools::XmlDocument.open('data/test.xml')

    xml_doc.add_namespaces xml_doc.root, jkr: 'http://JKRowling.com', node_ns: 'jkr'

    expect(xml_doc.to_xml).to eq(<<-END.align_left)
      <?xml version="1.0" encoding="utf-8"?>
      <jkr:patron xmlns:jkr="http://JKRowling.com">
        <name>Harry Potter</name>
        <barcode library="Hogwarts Library">1234567890</barcode>
        <access_level>student</access_level>
        <email>harry.potter@hogwarts.edu</email>
        <email>hpotter@JKRowling.com</email>
      </jkr:patron>
    END

  end

  it 'should search for nodes in the current document root' do
    xml_doc = ::LIBIS::Tools::XmlDocument.open('data/test.xml')

    nodes = xml_doc.xpath('//email')
    expect(nodes.size).to be 2
    expect(nodes.map(&:content)).to eq %w'harry.potter@hogwarts.edu hpotter@JKRowling.com'

  end

  it 'should check if the XML document contains certain element(s)' do
    xml_doc = ::LIBIS::Tools::XmlDocument.open('data/test.xml')

    expect(xml_doc.has_element? 'barcode[@library="Hogwarts Library"]').to be_truthy

  end

  it 'should return the content of the first element found' do
    xml_doc = ::LIBIS::Tools::XmlDocument.open('data/test.xml')

    expect(xml_doc.value('//email')).to eq 'harry.potter@hogwarts.edu'

  end

  it 'should return the content of all elements found' do
    xml_doc = ::LIBIS::Tools::XmlDocument.open('data/test.xml')

    expect(xml_doc.values('//email')).to eq %w'harry.potter@hogwarts.edu hpotter@JKRowling.com'

  end

  it 'should return the content of the first element in the set of nodes' do
    xml_doc = ::LIBIS::Tools::XmlDocument.open('data/test.xml')

    expect(::LIBIS::Tools::XmlDocument.get_content(xml_doc.xpath('//email'))).to eq 'harry.potter@hogwarts.edu'
  end

  it 'should Find a node and set its content' do
    xml_doc = ::LIBIS::Tools::XmlDocument.open('data/test.xml')

    xml_doc['//access_level'] = 'postgraduate'

    expect(xml_doc.to_xml).to eq <<-END.align_left
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
    xml_doc = ::LIBIS::Tools::XmlDocument.open('data/test.xml')

    expect(xml_doc.email.content).to eq 'harry.potter@hogwarts.edu'
    expect(xml_doc.barcode 'library').to eq 'Hogwarts Library'

    xml_doc.access_level = 'postgraduate'
    xml_doc.barcode 'library', 'Hogwarts Dumbledore Library'
    # noinspection RubyResolve
    xml_doc.dates do |dates|
      dates.birth_date '1980-07-31'
      dates.member_since '1991-09-01'
    end

    expect(xml_doc.to_xml).to eq <<-END.align_left
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
    xml_doc = ::LIBIS::Tools::XmlDocument.parse(<<-END.align_left)
      <patron>
        <name>Harry Potter</name>
        <barcode library="Hogwarts Library">1234567890</barcode>
        <access_level>student</access_level>
        <email>harry.potter@hogwarts.edu</email>
        <email>hpotter@JKRowling.com</email>
      </patron>
    END

    # <<-END.align_left
    #   <?xml version="1.0" encoding="utf-8"?>
    #   <patron>
    #     <name>Harry Potter</name>
    #     <barcode library="Hogwarts Library">1234567890</barcode>
    #     <access_level>student</access_level>
    #     <email>harry.potter@hogwarts.edu</email>
    #     <email>hpotter@JKRowling.com</email>
    #   </patron>
    # END

    expect(xml_doc.to_xml).to eq @xml_template

    xml_doc.save('/tmp/test.xml')

    xml_doc = ::LIBIS::Tools::XmlDocument.open('/tmp/test.xml')

    expect(xml_doc.to_xml).to eq @xml_template

    xml_doc = ::LIBIS::Tools::XmlDocument.build do
      # noinspection RubyResolve
      patron {
        name 'Harry Potter'
        barcode( '1234567890', library: 'Hogwarts Library')
        access_level 'student'
        email 'harry.potter@hogwarts.edu'
        email 'hpotter@JKRowling.com'
      }
    end

    expect(xml_doc.to_xml).to eq @xml_template

    xml_doc = ::LIBIS::Tools::XmlDocument.new
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

    expect(xml_doc.to_xml).to eq @xml_template

  end

end
