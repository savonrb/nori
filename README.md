Nori
====

[![CI](https://github.com/savonrb/nori/actions/workflows/test.yml/badge.svg)](https://github.com/savonrb/nori/actions/workflows/test.yml)
[![Gem Version](https://badge.fury.io/rb/nori.svg)](http://badge.fury.io/rb/nori)
[![Code Climate](https://codeclimate.com/github/savonrb/nori.svg)](https://codeclimate.com/github/savonrb/nori)

Really simple XML parsing ripped from Crack, which ripped it from Merb.  

Nori supports pluggable parsers and ships with both REXML and Nokogiri implementations.  
It defaults to Nokogiri since v2.0.0, but you can change it to use REXML via:

``` ruby
Nori.new(:parser => :rexml)  # or :nokogiri
```

Make sure Nokogiri is in your LOAD_PATH when parsing XML, because Nori tries to load it when it's needed.

# Examples

```ruby
Nori.new.parse("<tag>This is the content</tag>")
# => {"tag"=>"This is the content"}

Nori.new.parse('<foo />')
#=> {"foo"=>nil}

Nori.new.parse('<foo bar />')
#=> {}

Nori.new.parse('<foo bar="baz"/>')
#=> {"foo"=>{"@bar"=>"baz"}}

Nori.new.parse('<foo bar="baz">Content</foo>')
#=> {"foo"=>"Content"}
```

## Nori::StringWithAttributes

You can access a string node's attributes via `attributes`.

```ruby
result = Nori.new.parse('<foo bar="baz">Content</foo>')
#=> {"foo"=>"Content"}

result["foo"].class
# => Nori::StringWithAttributes

result["foo"].attributes
# => {"bar"=>"baz"}
```

## advanced_typecasting

Nori can automatically convert string values to `TrueClass`, `FalseClass`, `Time`, `Date`, and `DateTime`:

```ruby
# "true" and "false" String values are converted to `TrueClass` and `FalseClass`.
Nori.new.parse("<value>true</value>")
# => {"value"=>true}

# String values matching xs:time, xs:date and xs:dateTime are converted to `Time`, `Date` and `DateTime` objects.
Nori.new.parse("<value>09:33:55.7Z</value>")
# => {"value"=>2022-09-29 09:33:55.7 UTC

# disable with advanced_typecasting: false
Nori.new(advanced_typecasting: false).parse("<value>true</value>")
# => {"value"=>"true"}

```

## strip_namespaces

Nori can strip the namespaces from your XML tags. This feature is disabled by default.

``` ruby
Nori.new.parse('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"></soap:Envelope>')
# => {"soap:Envelope"=>{"@xmlns:soap"=>"http://schemas.xmlsoap.org/soap/envelope/"}}

Nori.new(:strip_namespaces => true).parse('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"></soap:Envelope>')
# => {"Envelope"=>{"@xmlns:soap"=>"http://schemas.xmlsoap.org/soap/envelope/"}}
```

## convert_tags_to

Nori lets you specify a custom formula to convert XML tags to Hash keys using `convert_tags_to`.

``` ruby
Nori.new.parse('<userResponse><accountStatus>active</accountStatus></userResponse>')
# => {"userResponse"=>{"accountStatus"=>"active"}}

parser = Nori.new(:convert_tags_to => lambda { |tag| Nori::StringUtils.snakecase(tag).to_sym })
parser.parse('<userResponse><accountStatus>active</accountStatus></userResponse>')
# => {:user_response=>{:account_status=>"active"}}
```

## convert_dashes_to_underscores

By default, Nori will automatically convert dashes in tag names to underscores.

```ruby
Nori.new.parse('<any-tag>foo bar</any-tag>')
# => {"any_tag"=>"foo bar"}

# disable with convert_dashes_to_underscores
parser = Nori.new(:convert_dashes_to_underscores => false)
parser.parse('<any-tag>foo bar</any-tag>')
# => {"any-tag"=>"foo bar"}
```
