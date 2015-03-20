[![Build Status](https://travis-ci.org/Kris-LIBIS/LIBIS_Tools.svg?branch=master)](https://travis-ci.org/Kris-LIBIS/LIBIS_Tools)
[![Coverage Status](https://img.shields.io/coveralls/Kris-LIBIS/LIBIS_Tools.svg)](https://coveralls.io/r/Kris-LIBIS/LIBIS_Tools)
[![Dependency Status](https://gemnasium.com/Kris-LIBIS/LIBIS_Tools.svg)](https://gemnasium.com/Kris-LIBIS/LIBIS_Tools)
<!--[![Code Climate](https://codeclimate.com/github/Kris-LIBIS/LIBIS_Tools/badges/gpa.svg)](https://codeclimate.com/github/Kris-LIBIS/LIBIS_Tools)
[![Test Coverage](https://codeclimate.com/github/Kris-LIBIS/LIBIS_Tools/badges/coverage.svg)](https://codeclimate.com/github/Kris-LIBIS/LIBIS_Tools)
-->

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

### assert

The Object#assert method enables the assert functionality found in other languages.
The method takes an argument that will be interpreted as a boolean expression and an optional message.
If the boolean expression evaluates to false an AssertionFailure exception will be raised.

Alternatively, if a block is passed to the method, the given block will be evaluated and the result will decide if the
exception will be raised. In that case the first argument passed to the assert method is used as message and the second
argument is ignored.

The method will not evaluate the first parameter or block unless the general parameter $DEBUG evaluates to true. That
means that special care should be taken that the expression does not generate any side effects that the program may rely
on.

Examples:

```ruby
    require 'libis/tools/assert'
    assert(value > 0, 'value should be positive number')
```
and using a code block:

```ruby
    require 'libis/tools/assert'
    assert 'database is not idle' do
        db = get_database
        db.status == :IDLE
    end
```

### Checksum

The ::Libis::Tools::Checksum class offers a standardized interface for calculating checksums of file contents in
different formats. The actual list of supported checksum formats is in ::Libis::Tools::Checksum.CHECKSUM_TYPES. It
contains MD5, SHA-1 and SHA-2 (in 256-bit, 384-bit and 512-bit variants).

There are two ways this can be used: using a class instance or using class methods. When a class instance is used, the
desired checksum type has to be supplied when the instance is created. Each call to a checksum method will calculate the
checksum and reset the digest to prevent future calls to be affected by the current result. When a class method is used
besides the file name, the checksum type has to be supplied.

The available methods on both instance and class level are:

* digest: return the checksum as (binary) string.
* hexdigest: return the checksum as hexadecimal encoded string.
* base64digest: return the checksum as base64 encoded string.

Examples:

```ruby
    require 'libis/tools/checksum'
    checksum = ::Libis::Tools::Checksum.new(:MD5)
    puts "Checksum: #{checksum.hexdigest(file_name)} (MD5, hex)"
```

```ruby
    require 'libis/tools/checksum'
    puts "Checksum: #{::Libis::Tools::Checksum.base64digest(file_name, :SHA384)} (SHA-2, 384 bit, base64)"
```

### Command

This module allows to run an external command safely and returns it's output, error messages and status. The run method
takes any number of arguments that will be used as command-line arguments. The method returns a Hash with:

* :out => an array with lines that were printed on the external program's standard out.
* :err => an array with lines that were printed on the external program's standard error.
* :status => exit code returned by the external program.

```ruby
    require 'libis/tools/command'
    result = ::Libis::Tools::Command.run('ls', '-l', File.absolute_path(__FILE__))
    p result # => {out: [...], err: [...], status: 0}
```

or:

```ruby
    require 'libis/tools/command'
    include ::Libis::Tools::Command
    result = run('ls', '-l', File.absolute_path(__FILE__))
    p result # => {out: [...], err: [...], status: 0}
```

Note that the Command class uses Open3#popen3 internally. All arguments supplied to Command#run are passed to the popen3
call. Unfortunately JRuby has some known issues with popen3. Please use and test carefully in JRuby environments.

### Config

The Config class is a convenience method for easy configuration maintenance and loading. It supports code defaults,
loading configurations from multiple YAML files containing ERB statements. The Config class follows the Singleton
pattern and behaves like a Hash/OpenStruct/HashWithIndifferentAccess. It also initializes a default Logger instance.

For each configuration parameter, the value can be accessed via the class or the Singleton instance through a method
call or via the Hash operator using the parameter name either as a string or a symbol.

Examples:

```ruby
    require 'libis/tools/config'
    cfg = ::Libis::Tools::Config
    cfg['my_value'] = 10
    p cfg.instance.my_value # => 10
    cfg.instance.my_text = 'abc'
    p cfg[:my_text] # => 'abc'
    p cfg.logger.warn('message') # => W, [2015-03-16T12:51:01.180548 #28935]  WARN -- : message
```

### Logger

The Logger module adds logging functionality to any class. Just include the ::Libis::Tools::Logger module and the
methods debug, info, warn, error and fatal will be available to the class instance. Each method takes a message argument
and optional extra parameters. The methods all call the message method with the logging level as first argument and the
supplied arguments appended.

The default message method implementation uses the logger of ::Libis::Tools::Config. If extra parameters are supplied,
the message will be used as a format specification with the extra parameters applied to it. If an 'appname' parameter is
defined in the Config object, it will be used as program name by the logger, otherwise the class name is taken.

If the class defines a #options method that returns a Hash containing a :quiet key, the value for that key will be
evaluated and if true debug, info and warning messages will not be printed.

Example:

```ruby
    require 'libis/tools/logger'
    class TestLogger
      include ::Libis::Tools::Logger
      attr_accessor :options, name
      def initialize
        @options = {}
        @name = nil
      end
    end
    tl = TestLogger.new
    tl.debug 'message'
    tl.options[:quiet] = true
    tl.warn 'message'
    ::Libis::Tools::Config.appname = 'TestApplication'
    tl.error 'huge error: [%d] %s', 1000, 'Exit'
    tl.name = 'TestClass'
    tl.options[:quiet] = false
    tl.info 'Running application: %s', ::Libis::Tools::Config.appname
```
produces:
    <pre>
    D, [...] DEBUG -- TestLogger: message
    E, [...] ERROR -- TestApplication: huge error: [1000] Exit
    I, [...]  INFO -- TestClass: Running application TestApplication
    </pre>

### XmlDocument

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
