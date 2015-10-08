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

### DeepStruct

A class that derives from OpenStruct through the RecursiveOpenStruct. A RecursiveOpenStruct is derived from stdlib's
OpenStruct, but can be made recursive. DeepStruct enforces this behaviour and adds a clear! method.

### ConfigFile

A base class for Config, but useable on it's own. It extends the DeepStruct with << and >> methods that supports
loading and saving of configuration values from and to files. Note that ERB commands will get lost during a round-trip.
 
```ruby
    require 'libis/tools/config_file'
    cfg_file = ::Libis::Tools::ConfigFile.new
    cfg_file << {foo: 'bar'}
    cfg_file.my_value = 10
    p cfg_file[:my_value] # => 10
    cfg_file{:my_text] = 'abc'
    p cfg_file['my_text'] # => 'abc'
    p cfg_file.to_hash # => { :foo => 'bar', 'my_value' => 10, :my_text => 'abc' }
    cfg >> 'my_config.yml'
```
### Config

The Config class is a convenience class for easy configuration maintenance and loading. Based on ConfigFile and 
DeepStruc, it supports code defaults and loading configurations from multiple YAML files containing ERB statements.
The Config class follows the Singleton pattern and behaves like a Hash/OpenStruct/HashWithIndifferentAccess with 
recursion over hashes and arrays. It also initializes a default Logger instance.

For each configuration parameter, the value can be accessed via the class or the Singleton instance through a method
call or via the Hash operator using the parameter name either as a string or a symbol.

Examples:

```ruby
    require 'libis/tools/config'
    cfg = ::Libis::Tools::Config
    cfg << 'my_config.yml'
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
    
## Metadata

This gem also provides some modules and classes that assist in working with metadata. There are classes that allow to 
create and/or read metadata for MARC(21), Dublin Core and SharePoint. These classes all live in the 
Libis::Tools::Metadata namespace.

### MARC

The classes Libis::Tools::Metadata::MarcRecord and it's child class Libis::Tools::Metadata::Marc21Record are mainly
built for reading MARC(21) records. Most of the class logic is in the base class MarcRecord, which is incomplete and
should be considered an abstract class. Marc21Record on the other hand only contains the logic to parse the XML data 
into the internal structure. A MarcRecord is created by supplying it an XML node (from Nokogiri or 
Libis::Tools::XmlDocument) that contains child nodes with the MARC data of a single record. The code will strip
namespaces from the input in order to greatly simplify working with the XML.
 
## Parameter

The class ::Libis::Tools::Parameter and the ::Libis::Tools::ParameterContainer module provide a simple framework for
instance variables that are type-safe and can easily be documented and provide defaults.
 
To use these parameters a class should include the ::Libis::Tools::ParameterContainer module and add 'parameter' 
statements to the body of the class definition. It takes only one mandatory argument which is a Hash. The first entry is
interpreted as '<name> => <default>'. The name for the parameter should be unique and the default value can be any value
of type TrueClass, FalseClass, String, Integer, Float, Date, Time, DateTime, Array, Hash or NilClass.

The second up to last Hash entries are optional properties for the parameter. These are:

* datatype: the type of values the parameter will accept. Valid values are:

    * 'bool' or 'boolean'
    * 'string'
    * 'int'
    * 'float'
    * 'datetime'
    * 'array'
    * 'hash'

    Any other value will raise a RuntimeError when the parameter is used. The value is case-insensitive and if not present, 
    the datatype will be derived from the default value with 'string' being the default for NilClass. In any case the 
    parameter will try its best to convert supplied values to the proper data type. For instance, an Integer parameter will 
    accept 3, 3.1415, '3' and Rational(10/3) as valid values and store them as the integer value 3. Likewise DateTime 
    parameters will try to interprete date and time strings.

* description: any descriptive text you want to add to clarify what this parameter is used for. Any tool can ask the
class for its parameters and - for instance - can use this property to provide help in a GUI when asking the user for
input.

* constraint: adds a validation condition to the parameter. The condition value can be: 

    * an array: only values that convert to a value in the list are considered valid.
    * a range: only values that convert to a value in the given range are considered valid.
    * a regular expression: only values that match the regular expression are considered valid.
    * a string: only values that are '==' to the constraint are considered valid.
    
* frozen: if set to true, prevents the class instance to set the parameter to any value other than the default. Mostly
useful when a derived class needs a parameter in the parent class to be set to a specific value. Setting a value on 
a frozen parameter with the 'parameter(name,value)' method throws a ::Libis::Tools::ParameterFrozenError. The '[]=' 
method silently ignores the exception. In any case the default value will not be changed.

* options: a hash with any additional properties that you want to associate to the parameter. Any key-value pair in this
hash is added to the retrievable properties of the parameter. Likewise any property defined, that is not in the list of 
known properties is added to the options hash. In this aspect the ::Libis::Tools::Parameter class behaves much like an
OpenStruct even though it is implemented as a Struct.

Besides enabling the 'parameter' class method to define parameters, the ::Libis::Tools::ParameterContainer add the class
method 'parameters' that will return a Hash with parameter names as keys and their respective parameter definitions as
values. On each class instance the 'parameter' method is added and serves as both getter and setter for parameter values:
With only one argument (the parameter name) it returns the current value for the parameter, but the optional second 
argument will cause the method to set the parameter value. If the parameter is not available or the given value is not 
a valid value for the parameter, the method will return the special constant ::Libis::ParameterContainer::NO_VALUE. The 
methods '[]' and '[]=' serve as aliases for the getter and setter calls.

Additionally two protected methods are available on the instance:
* 'parameters': returns the Hash that keeps track of the current parameter values for the instance.
* 'get_parameter_defintion': retrieves the parameter definition from the instance's class for the given parameter name.

Any class that derives from a class that included the ::Libis::Tools::ParameterContainer module will automatically 
inherit all parameter definitions from all of it's base classes and can override any of these parameter definitions e.g. 
to change the default values for the parameter.

## Contributing

1. Fork it ( https://github.com/Kris-LIBIS/LIBIS_Tools/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
