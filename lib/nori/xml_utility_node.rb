require "rexml/text"
require "date"
require "time"
require "yaml"
require "bigdecimal"

require "nori/string_with_attributes"
require "nori/string_io_file"

module Nori

  # This is a slighly modified version of the XMLUtilityNode from
  # http://merb.devjavu.com/projects/merb/ticket/95 (has.sox@gmail.com)
  #
  # John Nunemaker:
  # It's mainly just adding vowels, as I ht cd wth n vwls :)
  # This represents the hard part of the work, all I did was change the
  # underlying parser.
  class XMLUtilityNode

    # Simple xs:time Regexp.
    XS_TIME = /\d{2}:\d{2}:\d{2}/

    # Simple xs:date Regexp.
    XS_DATE = /\d{4}-\d{2}-\d{2}/

    # Simple xs:dateTime Regexp.
    XS_DATE_TIME = /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/

    def self.typecasts
      @@typecasts
    end

    def self.typecasts=(obj)
      @@typecasts = obj
    end

    def self.available_typecasts
      @@available_typecasts
    end

    def self.available_typecasts=(obj)
      @@available_typecasts = obj
    end

    self.typecasts = {}
    self.typecasts["integer"]       = lambda { |v| v.nil? ? nil : v.to_i }
    self.typecasts["boolean"]       = lambda { |v| v.nil? ? nil : (v.strip != "false") }
    self.typecasts["datetime"]      = lambda { |v| v.nil? ? nil : Time.parse(v).utc }
    self.typecasts["date"]          = lambda { |v| v.nil? ? nil : Date.parse(v) }
    self.typecasts["dateTime"]      = lambda { |v| v.nil? ? nil : Time.parse(v).utc }
    self.typecasts["decimal"]       = lambda { |v| v.nil? ? nil : BigDecimal(v.to_s) }
    self.typecasts["double"]        = lambda { |v| v.nil? ? nil : v.to_f }
    self.typecasts["float"]         = lambda { |v| v.nil? ? nil : v.to_f }
    self.typecasts["symbol"]        = lambda { |v| v.nil? ? nil : v.to_sym }
    self.typecasts["string"]        = lambda { |v| v.to_s }
    self.typecasts["yaml"]          = lambda { |v| v.nil? ? nil : YAML.load(v) }
    self.typecasts["base64Binary"]  = lambda { |v| v.unpack('m').first }

    self.available_typecasts = self.typecasts.keys

    def initialize(name, normalized_attributes = {})
      # unnormalize attribute values
      attributes = Hash[* normalized_attributes.map do |key, value|
        [ key, unnormalize_xml_entities(value) ]
      end.flatten]

      @name = name.tr("-", "_")
      @name = @name.split(":").last if Nori.strip_namespaces?
      @name = Nori.convert_tag(@name) if Nori.convert_tags?

      # leave the type alone if we don't know what it is
      @type = self.class.available_typecasts.include?(attributes["type"]) ? attributes.delete("type") : attributes["type"]

      @nil_element = false
      attributes.keys.each do |key|
        if result = /^((.*):)?nil$/.match(key)
          @nil_element = attributes.delete(key) == "true"
          attributes.delete("xmlns:#{result[2]}") if result[1]
        end
      end
      @attributes = undasherize_keys(attributes)
      @children = []
      @text = false
    end

    attr_accessor :name, :attributes, :children, :type

    def prefixed_attributes
      attributes.inject({}) do |memo, (key, value)|
        memo[prefixed_attribute_name("@#{key}")] = value
        memo
      end
    end

    def prefixed_attribute_name(attribute)
      Nori.convert_tags? ? Nori.convert_tag(attribute) : attribute
    end

    def add_node(node)
      @text = true if node.is_a? String
      @children << node
    end

    def to_hash
      if @type == "file"
        f = StringIOFile.new((@children.first || '').unpack('m').first)
        f.original_filename = attributes['name'] || 'untitled'
        f.content_type = attributes['content_type'] || 'application/octet-stream'
        return { name => f }
      end

      if @text
        t = typecast_value unnormalize_xml_entities(inner_html)
        t = advanced_typecasting(t) if t.is_a?(String) && Nori.advanced_typecasting?

        if t.is_a?(String)
          t = StringWithAttributes.new(t)
          t.attributes = attributes
        end

        return { name => t }
      else
        #change repeating groups into an array
        groups = @children.inject({}) { |s,e| (s[e.name] ||= []) << e; s }

        out = nil
        if @type == "array"
          out = []
          groups.each do |k, v|
            if v.size == 1
              out << v.first.to_hash.entries.first.last
            else
              out << v.map{|e| e.to_hash[k]}
            end
          end
          out = out.flatten

        else # If Hash
          out = {}
          groups.each do |k,v|
            if v.size == 1
              out.merge!(v.first)
            else
              out.merge!( k => v.map{|e| e.to_hash[k]})
            end
          end
          out.merge! prefixed_attributes unless attributes.empty?
          out = out.empty? ? nil : out
        end

        if @type && out.nil?
          { name => typecast_value(out) }
        else
          { name => out }
        end
      end
    end

    # Typecasts a value based upon its type. For instance, if
    # +node+ has #type == "integer",
    # {{[node.typecast_value("12") #=> 12]}}
    #
    # @param value<String> The value that is being typecast.
    #
    # @details [:type options]
    #   "integer"::
    #     converts +value+ to an integer with #to_i
    #   "boolean"::
    #     checks whether +value+, after removing spaces, is the literal
    #     "true"
    #   "datetime"::
    #     Parses +value+ using Time.parse, and returns a UTC Time
    #   "date"::
    #     Parses +value+ using Date.parse
    #
    # @return <Integer, TrueClass, FalseClass, Time, Date, Object>
    #   The result of typecasting +value+.
    #
    # @note
    #   If +self+ does not have a "type" key, or if it's not one of the
    #   options specified above, the raw +value+ will be returned.
    def typecast_value(value)
      return value unless @type
      proc = self.class.typecasts[@type]
      proc.nil? ? value : proc.call(value)
    end

    def try_to_convert(value, &block)
      begin
        block.call(value)
      rescue Exception => e
        value
      end
    end

    def advanced_typecasting(value)
      split = value.split
      return value if split.size > 1

      case split.first
        when "true"       then true
        when "false"      then false
        when XS_DATE_TIME then try_to_convert(value) {|x| DateTime.parse(x)}
        when XS_DATE      then try_to_convert(value) {|x| Date.parse(x)}
        when XS_TIME      then try_to_convert(value) {|x| Time.parse(x)}
        else                   value
      end
    end

    # Take keys of the form foo-bar and convert them to foo_bar
    def undasherize_keys(params)
      params.keys.each do |key, value|
        params[key.tr("-", "_")] = params.delete(key)
      end
      params
    end

    # Get the inner_html of the REXML node.
    def inner_html
      @children.join
    end

    # Converts the node into a readable HTML node.
    #
    # @return <String> The HTML node in text form.
    def to_html
      attributes.merge!(:type => @type ) if @type
      "<#{name}#{attributes.to_xml_attributes}>#{@nil_element ? '' : inner_html}</#{name}>"
    end

    alias to_s to_html

  private

    # TODO: replace REXML
    def unnormalize_xml_entities value
      REXML::Text.unnormalize(value)
    end
  end

end
