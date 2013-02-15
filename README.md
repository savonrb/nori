Nori [![Build Status](https://secure.travis-ci.org/savonrb/nori.png)](http://travis-ci.org/savonrb/nori)
====

Really simple XML parsing ripped from Crack which ripped it from Merb.  
Nori was created to bypass the stale development of Crack, improve its XML parser  
and fix certain issues.

``` ruby
parser = Nori.new
parser.parse("<tag>This is the contents</tag>")
# => { 'tag' => 'This is the contents' }
```

Nori supports pluggable parsers and ships with both REXML and Nokogiri implementations.  
It defaults to REXML, but you can change it to use Nokogiri via:

``` ruby
Nori.new(:parser => :nokogiri)  # or :rexml
```

Make sure Nokogiri is in your LOAD_PATH when parsing XML, because Nori tries to load it  
when it's needed.


Typecasting
-----------

Besides regular typecasting, Nori features somewhat "advanced" typecasting:

* "true" and "false" String values are converted to `TrueClass` and `FalseClass`.
* String values matching xs:time, xs:date and xs:dateTime are converted
  to `Time`, `Date` and `DateTime` objects.

You can disable this feature via:

``` ruby
Nori.new(:advanced_typecasting => false)
```


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
