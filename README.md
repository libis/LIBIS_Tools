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

## {::Libis::Tools::Parameter} and {::Libis::Tools::ParameterContainer}

The class {::Libis::Tools::Parameter} and the {::Libis::Tools::ParameterContainer} module provide a simple framework for
instance variables that are type-safe and can easily be documented and provide defaults.

## {::Libis::Tools::TempFile}

A small and simple module that provides some convenience methods to deal with temp files. Random file names are generated
in a similar way as the standard Ruby Tempfile class does. It has the form:
```
    <Optional prefix with '_' appended><YYYYMMDD>_<process id>_<random base36 number><optional suffix>
```

The #name method creates a random file name. Optional parameters are the prefix and suffix (including '.' character if
needed) for the temp file name and the directory part of the file path. Without directory option the file path will be
located in the standard folder for temporary files (e.g. /tmp on Linux).

The #file method creates a random file name as above, but immediately opens it for writing. If a block is given, the open
file pointer (IO object) will be passed as argument to the block and the file will automatically be closed and deleted
when the block ends. In that case the return value will be whatever the block returns.

Without a block, the method still creates and opens the file, but it will return the open file pointer to the caller. The
caller is responsible to #close and #unlink or #delete the file. The #unlink and #delete methods are injected into the
returned IO object for your convenience, but calling the corresponding File methods instead is equally valid.

## {::Libis::Tools::ThreadSafe}

A convenience method that embeds the mutex implementation. Just include this module whenever you need a thread-save
implementation and use the mutex instance variable without any concerns regarding initialization. Your class will have
access to an instance variable 'mutex' as well as a class variable 'class_mutex'. The mutexes (Montor instance) themselves
are created in a thread-safe way.

## {::Libis::Tools::XmlDocument}

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
