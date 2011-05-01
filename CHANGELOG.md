== UPCOMING

* Changes XML attributes converted to Hash keys to be prefixed with an @-sign.  
  This avoids problems with attributes and child nodes having the same name.  

  For example:

      <multiRef id="id1">
        <approved xsi:type="xsd:boolean">true</approved>
        <id xsi:type="xsd:long">76737</id>
      </multiRef>

  is now translated to:

      { "multiRef" => { "@id" => "id1", "id" => "76737", "approved" => "true" } }

== 0.2.0 (2011-04-30)

* Removed JSON from the original Crack basis
* Fixed a problem with Object#blank?
* Added swappable parsers
* Added a Nokogiri parser with you can switch to via:

      Nori.parser = :nokogiri

== 0.1.7 2010-02-19
* 1 minor patch
  * Added patch from @purp for ISO 8601 date/time format

== 0.1.6 2010-01-31
* 1 minor patch
  * Added Crack::VERSION constant - http://weblog.rubyonrails.org/2009/9/1/gem-packaging-best-practices

== 0.1.5 2010-01-27
* 1 minor patch
  * Strings that begin with dates shouldn't be parsed as such (sandro)

== 0.1.3 2009-06-22
* 1 minor patch
  * Parsing a text node with attributes stores them in the attributes method (tamalw)

== 0.1.2 2009-04-21
* 2 minor patches
  * Correct unnormalization of attribute values (der-flo)
  * Fix error in parsing YAML in the case where a hash value ends with backslashes, and there are subsequent values in the hash (deadprogrammer)

== 0.1.1 2009-03-31
* 1 minor patch
  * Parsing empty or blank xml now returns empty hash instead of raising error.

== 0.1.0 2009-03-28
* Initial release.
