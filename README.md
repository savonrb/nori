Nori ![http://travis-ci.org/rubiii/nori](http://travis-ci.org/rubiii/nori.png)
====

Really simple XML parsing ripped from Crack which ripped it from Merb.
Nori was created to bypass the stale development of Crack, improve its XML parser
and fix certain issues.

``` ruby
Nori.parse("<tag>This is the contents</tag>")
# => { 'tag' => 'This is the contents' }
```

Nori supports pluggable parsers and ships with both REXML and Nokogiri implementations.
It defaults to REXML, but you can change it to use Nokogiri via:

``` ruby
Nori.parser = :nokogiri
```

Make sure Nokogiri is in your LOAD_PATH when parsing XML, because Nori tries to load it
when it's needed.
