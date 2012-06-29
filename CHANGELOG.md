## 2.0.0 (UPCOMING)

* Major change: Removed attributes from values and moved them to `Object#xml_attributes`.
  Even though I don't like extending Object, this change solves a lot of problems and confusion
  with XML attributes and values.

    ``` xml
    <Contact xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <Name xsi:type="xsd:string">Some name in here</Name>
      <Address xsi:nil="true"></Address>
    </Contact>
    ```

  What you got before this change was the "Name" without the attribute
  and the `xsi` attribute from the "Contact" node prefixed with an @.

    ``` ruby
    old = {
      "Contact" => {
        "Name" => "Some name in here",
        "Address" => nil,
        "@xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance"
      }
    }
    ```

  What you get now, is this:

    ``` ruby
    new = {
      "Contact" => {
        "Name" => "Some name in here",
        "Address" => nil
      }
    }
    ```

  No namespaces in your Hashes. If you need to access the attributes of node,
  they are now stored on the nodes value.

    ``` ruby
    new["Contact"].xml_attributes  # => { "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance" }
    new["Contact"]["Name"].xml_attributes  # => { "xsi:type" => "xsd:string" }
    ```

## 1.1.2 (2012-02-30)

* Fix: Reverted `Object#xml_attributes` feature which is planned for version 2.0.

## 1.1.1 (2012-02-29) - yanked

* Fix: Merged [pull request 17](https://github.com/rubiii/nori/pull/17) for improved
  xs:time/xs:date/xs:dateTime regular expression matchers.

## 1.1.0 (2012-02-17)

* Improvement: Merged [pull request 9](https://github.com/rubiii/nori/pull/9) to
  allow multiple configurations of Nori.

* Fix: Merged [pull request 10](https://github.com/rubiii/nori/pull/10) to handle
  date/time parsing errors. Fixes a couple of similar error reports.

## 1.0.2 (2011-07-04)

* Fix: When specifying a custom formula to convert tags, XML attributes were ignored.
  Now, a formula is applied to both XML tags and attributes.

## 1.0.1 (2011-06-21)

* Fix: Make sure to always load both StringWithAttributes and StringIOFile
  to prevent NameError's.

## 1.0.0 (2011-06-20)

* Notice: As of v1.0.0, Nori will follow [Semantic Versioning](http://semver.org).

* Feature: Added somewhat advanced typecasting:

  What this means:

  * "true" and "false" are converted to TrueClass and FalseClass
  * Strings matching an xs:time, xs:date and xs:dateTime are converted
    to Time, Date and DateTime objects.

  You can disable this feature via:

      Nori.advanced_typecasting = false

* Feature: Added an option to strip the namespaces from every tag.
  This feature might raise problems and is therefore disabled by default.

      Nori.strip_namespaces = true

* Feature: Added an option to specify a custom formula to convert tags.
  Here's an example:

      Nori.configure do |config|
        config.convert_tags_to { |tag| tag.snake_case.to_sym }
      end

      xml = '<userResponse><accountStatus>active</accountStatus></userResponse>'
      parse(xml).should ## { :user_response => { :account_status => "active" }

## 0.2.4 (2011-06-21)

* Fix: backported fixes from v1.0.1

## 0.2.3 (2011-05-26)

* Fix: Use extended core classes StringWithAttributes and StringIOFile instead of
  creating singletons to prevent serialization problems.

## 0.2.2 (2011-05-16)

* Fix: namespaced xs:nil values should be nil objects.

## 0.2.1 (2011-05-15)

* Fix: Changed XML attributes converted to Hash keys to be prefixed with an @-sign.  
  This avoids problems with attributes and child nodes having the same name.

      <multiRef id="id1">
        <approved xsi:type="xsd:boolean">true</approved>
        <id xsi:type="xsd:long">76737</id>
      </multiRef>

  is now translated to:

      { "multiRef" => { "@id" => "id1", "id" => "76737", "approved" => "true" } }

## 0.2.0 (2011-04-30)

* Removed JSON from the original Crack basis
* Fixed a problem with Object#blank?
* Added swappable parsers
* Added a Nokogiri parser with you can switch to via:

      Nori.parser = :nokogiri

## 0.1.7 2010-02-19
* 1 minor patch
  * Added patch from @purp for ISO 8601 date/time format

## 0.1.6 2010-01-31
* 1 minor patch
  * Added Crack::VERSION constant - http://weblog.rubyonrails.org/2009/9/1/gem-packaging-best-practices

## 0.1.5 2010-01-27
* 1 minor patch
  * Strings that begin with dates shouldn't be parsed as such (sandro)

## 0.1.3 2009-06-22
* 1 minor patch
  * Parsing a text node with attributes stores them in the attributes method (tamalw)

## 0.1.2 2009-04-21
* 2 minor patches
  * Correct unnormalization of attribute values (der-flo)
  * Fix error in parsing YAML in the case where a hash value ends with backslashes, and there are subsequent values in the hash (deadprogrammer)

## 0.1.1 2009-03-31
* 1 minor patch
  * Parsing empty or blank xml now returns empty hash instead of raising error.

## 0.1.0 2009-03-28
* Initial release.
