Nori
====

[![Build Status](https://secure.travis-ci.org/savonrb/nori.png)](http://travis-ci.org/savonrb/nori)
[![Gem Version](https://badge.fury.io/rb/nori.png)](http://badge.fury.io/rb/nori)
[![Code Climate](https://codeclimate.com/github/savonrb/nori.png)](https://codeclimate.com/github/savonrb/nori)
[![Coverage Status](https://coveralls.io/repos/savonrb/nori/badge.png?branch=master)](https://coveralls.io/r/savonrb/nori)


Really simple XML parsing ripped from Crack which ripped it from Merb.  
Nori was created to bypass the stale development of Crack, improve its XML parser  
and fix certain issues.

``` ruby
parser = Nori.new
parser.parse("<tag>This is the contents</tag>")
# => { 'tag' => 'This is the contents' }
```

Nori supports pluggable parsers and ships with both REXML and Nokogiri implementations.  
It defaults to Nokogiri since v2.0.0, but you can change it to use REXML via:

``` ruby
Nori.new(:parser => :rexml)  # or :nokogiri
```

Make sure Nokogiri is in your LOAD_PATH when parsing XML, because Nori tries to load it  
when it's needed.


Typecasting
-----------


### Auto-Detection / Advanced Typecasting

Nori supports auto detection for text nodes without a defined type,
beside the regular typecasting mechanism that uses the type attribute for conversion.
This option is called **:advanced_typecasting** and can currently detect and cast:

* "true" and "false" values
* XMLSchema types: time, date, dateTime

It is enabled by default and must be disabled explicitly:

``` ruby
Nori.new(:advanced_typecasting => false)
```

see [Nori::TypeConverter::Autodetect](lib/nori/type_converter.rb)


### Custom Type Conversion

Custom types can be converted easily with custom conversions.

E.g to convert a range of integers:

#### XML

``` xml
<?xml version="1.0" encoding="UTF-8"?>
  <officeHours type="interval">8..17</officeHours>
```

#### Custom Conversion Class

```ruby
class ToIntRange
  def self.convert(value)
    return nil if (value.nil? || value.length == 0)
    range = value.split('..')
    return range.first.to_i..range.last.to_i
  end
end

type_converter = Nori::TypeConverter.new('interval' => ToIntRange)
nori = Nori.new(:type_converter => type_converter)
nori.parse(xml)
```

### Namespace Prefix Detection

**Nori::TypeConverter** does type conversion based on the type attribute.
By default the namespace prefix for the type attribute and the type value is empty.
In order to use a non-empty namespace prefix it provides builtin namespace detection for
**XMLSchema / XMLSchema-instance** namespace:

```ruby
  xml = request.body.read
  type_converter = Nori::DEFAULT_TYPE_CONVERTER.tap {|c| c.detect_namespace_prefixes!(xml)}
  nori = Nori.new(:type_converter => type_converter)
```

* You can also use custom namespaces - see [TypeConverter spec](spec/nori/type_converter_spec.rb)

Namespaces
----------

Nori can strip the namespaces from your XML tags. This feature might raise  
problems and is therefore disabled by default. Enable it via:

``` ruby
Nori.new(:strip_namespaces => true)
```


XML tags -> Hash keys
---------------------

Nori lets you specify a custom formula to convert XML tags to Hash keys.  
Let me give you an example:

``` ruby
parser = Nori.new(:convert_tags_to => lambda { |tag| tag.snakecase.to_sym })

xml = '<userResponse><accountStatus>active</accountStatus></userResponse>'
parser.parse(xml)  # => { :user_response => { :account_status => "active" }
```
