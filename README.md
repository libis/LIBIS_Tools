[![Gem Version](https://badge.fury.io/rb/libis-tools.svg)](http://badge.fury.io/rb/libis-tools)
[![Build Status](https://travis-ci.org/Kris-LIBIS/LIBIS_Tools.svg?branch=master)](https://travis-ci.org/Kris-LIBIS/LIBIS_Tools)
[![Coverage Status](https://img.shields.io/coveralls/Kris-LIBIS/LIBIS_Tools.svg)](https://coveralls.io/r/Kris-LIBIS/LIBIS_Tools)
[![Dependency Status](https://gemnasium.com/Kris-LIBIS/LIBIS_Tools.svg)](https://gemnasium.com/Kris-LIBIS/LIBIS_Tools)

# Libis::Tools

This gem contains some generic helper methods, classes and modules that should be easily reusable in other projects.

## Installation

Add this line to your application's Gemfile:

```ruby
    gem 'libis-tools'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install libis-tools

## Usage

In order to make available all the code the gem supplies a single file can be included:

```ruby
    require 'libis-tools'
```

or:

```ruby
    require 'libis/tools'
```

Alternatively, if you only want to use a single class or module, partial files are available. See the examples in the
sections below for their names.

## Content

### {Object#assert}

The {Object#assert} method enables the assert functionality found in other languages. Since it is defined on the
Object class, it is available on almost any class.

### {::Libis::Tools::Checksum}

The {::Libis::Tools::Checksum} class offers a standardized interface for calculating checksums of file 
contents in different formats.

### {::Libis::Tools::Command}

The {::Libis::Tools::Command} module offers a safe way to execute external commands and gives you access to the 
exit status as well as standard output and standard error information. May have issues on older JRuby versions. 

### {::Libis::Tools::DeepStruct}

A class that derives from OpenStruct through the RecursiveOpenStruct.
By wrapping a Hash recursively, it allows for easy access to the content by method names.

### {::Libis::Tools::ConfigFile}

A base class for {::Libis::Tools::Config}, but useable on it's own.
It extends the DeepStruct with loading from and saving to YAML files.

### {::Libis::Tools::Config}

This Singleton class is a convenience class for easy configuration maintenance and loading.
It also initializes a default logger.

### {::Libis::Tools::Logger}

The ::Libis::Tools::Logger module adds support for logging functionality to any class.

## {::Libis::Tools::Metadata}

This gem also provides some modules and classes that assist in working with metadata. There are classes that allow to 
create and/or read metadata for MARC(21), Dublin Core and SharePoint. These classes all live in the 
Libis::Tools::Metadata namespace.

### MARC

The classes {::Libis::Tools::Metadata::MarcRecord} and it's child class {::Libis::Tools::Metadata::Marc21Record} are 
mainly built for reading MARC(21) records. Most of the class logic is in the base class 
{::Libis::Tools::Metadata::MarcRecord MarcRecord}, which is incomplete and should be considered an abstract class. 

{::Libis::Tools::Metadata::Marc21Record Marc21Record} on the other hand only contains the logic to parse the XML data 
into the internal structure. A {::Libis::Tools::Metadata::MarcRecord MarcRecord} is created by supplying it an XML node
(from Nokogiri or {::Libis::Tools::XmlDocument}) that contains child nodes with the MARC data of a single record. 

The code will strip namespaces from the input in order to greatly simplify working with the XML.

## {::Libis::Tools::Parameter} and {::Libis::Tools::ParameterContainer} 

The class {::Libis::Tools::Parameter} and the {::Libis::Tools::ParameterContainer} module provide a simple framework for
instance variables that are type-safe and can easily be documented and provide defaults.

### {::Libis::Tools::XmlDocument}

Class that embodies most used features of Nokogiri, Nori and Gyoku in one convenience class. The Nokogiri document is
stored in the class variable 'document' and can be accessed and manipulated directly - if required. The class supports
the Nokogiri Build syntax for creating XML documents in a compact DSL. It also allows you to check the document against
an XML Schema and provides shorthand notations for accessing nodes and attributes.

Example:

```ruby
    xml_doc = ::Libis::Tools::XmlDocument.parse(<<-END.align_left)
      <patron>
        <name>Harry Potter</name>
        <barcode library="Hogwarts Library">1234567890</barcode>
        <access_level>student</access_level>
        <email>harry.potter@hogwarts.edu</email>
        <email>hpotter@JKRowling.com</email>
      </patron>
    END
    puts '---parse---', xml_doc.to_xml
    xml_doc.save('/tmp/test.xml')
    xml_doc = ::Libis::Tools::XmlDocument.open('/tmp/test.xml')
    puts '---save/open---', xml_doc.to_xml
    xml_doc = ::Libis::Tools::XmlDocument.build do
      patron {
        name 'Harry Potter'
        barcode( '1234567890', library: 'Hogwarts Library')
        access_level 'student'
        email 'harry.potter@hogwarts.edu'
        email 'hpotter@JKRowling.com'
      }
    end
    puts '---build---', xml_doc.to_xml
    xml_doc = ::Libis::Tools::XmlDocument.new
    xml_doc.add_node :patron
    xml_doc.name = 'Harry Potter'
    xml_doc.barcode = '1234567890'
    xml_doc.barcode :library, 'Hogwarts Library'
    xml_doc.access_level = 'student'
    xml_doc.email = 'harry.potter@hogwarts.edu'
    xml_doc.add_node :email, 'hpotter@JKRowling.com'
    # Note: xml_doc.email('hpotter@JKRowling.com') whould not have created a new node.
    #           It would override the first email element
    puts '---method---', xml_doc.to_xml
```

produces:

    ---parse---
    <?xml version="1.0" encoding="utf-8"?>
    <patron>
      <name>Harry Potter</name>
      <barcode library="Hogwarts Library">1234567890</barcode>
      <access_level>student</access_level>
      <email>harry.potter@hogwarts.edu</email>
      <email>hpotter@JKRowling.com</email>
    </patron>
    ---save/open---
    <?xml version="1.0" encoding="utf-8"?>
    <patron>
      <name>Harry Potter</name>
      <barcode library="Hogwarts Library">1234567890</barcode>
      <access_level>student</access_level>
      <email>harry.potter@hogwarts.edu</email>
      <email>hpotter@JKRowling.com</email>
    </patron>
    ---build---
    <?xml version="1.0" encoding="utf-8"?>
    <patron>
      <name>Harry Potter</name>
      <barcode library="Hogwarts Library">1234567890</barcode>
      <access_level>student</access_level>
      <email>harry.potter@hogwarts.edu</email>
      <email>hpotter@JKRowling.com</email>
    </patron>
    ---method---
    <?xml version="1.0" encoding="utf-8"?>
    <patron>
      <name>Harry Potter</name>
      <barcode library="Hogwarts Library">1234567890</barcode>
      <access_level>student</access_level>
      <email>harry.potter@hogwarts.edu</email>
      <email>hpotter@JKRowling.com</email>
    </patron>
 
## Contributing

1. Fork it ( https://github.com/Kris-LIBIS/LIBIS_Tools/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
