require "date"
require "time"
require "yaml"
require "bigdecimal"

require "nori/string_with_attributes"
require "nori/string_io_file"

class Nori

  # This is a slighly modified version of the XMLUtilityNode from
  # http://merb.devjavu.com/projects/merb/ticket/95 (has.sox@gmail.com)
  #
  # John Nunemaker:
  # It's mainly just adding vowels, as I ht cd wth n vwls :)
  # This represents the hard part of the work, all I did was change the
  # underlying parser.
  class XMLUtilityNode

    # Simple xs:time Regexp.
    # Valid xs:time formats
    # 13:20:00          1:20 PM
    # 13:20:30.5555     1:20 PM and 30.5555 seconds
    # 13:20:00-05:00    1:20 PM, US Eastern Standard Time
    # 13:20:00+02:00    1:20 PM, Central European Standard Time
    # 13:20:00Z         1:20 PM, Coordinated Universal Time (UTC)
    # 13:20:30.5555Z    1:20 PM and 30.5555 seconds, Coordinated Universal Time (UTC)
    # 00:00:00          midnight
    # 24:00:00          midnight

    XS_TIME = /^\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:?\d{2})?$/

    # Simple xs:date Regexp.
    # Valid xs:date formats
    # 2004-04-12           April 12, 2004
    # -0045-01-01          January 1, 45 BC
    # 12004-04-12          April 12, 12004
    # 2004-04-12-05:00     April 12, 2004, US Eastern Standard Time, which is 5 hours behind Coordinated Universal Time (UTC)
    # 2004-04-12+02:00     April 12, 2004, Central European Summer Time, which is 2 hours ahead of Coordinated Universal Time (UTC)
    # 2004-04-12Z          April 12, 2004, Coordinated Universal Time (UTC)

    XS_DATE = /^-?\d{4}-\d{2}-\d{2}(?:Z|[+-]\d{2}:?\d{2})?$/

    # Simple xs:dateTime Regexp.
    # Valid xs:dateTime formats
    # 2004-04-12T13:20:00           1:20 pm on April 12, 2004
    # 2004-04-12T13:20:15.5         1:20 pm and 15.5 seconds on April 12, 2004
    # 2004-04-12T13:20:00-05:00     1:20 pm on April 12, 2004, US Eastern Standard Time
    # 2004-04-12T13:20:00+02:00     1:20 pm on April 12, 2004, Central European Summer Time
    # 2004-04-12T13:20:15.5-05:00   1:20 pm and 15.5 seconds on April 12, 2004, US Eastern Standard Time
    # 2004-04-12T13:20:00Z          1:20 pm on April 12, 2004, Coordinated Universal Time (UTC)
    # 2004-04-12T13:20:15.5Z        1:20 pm and 15.5 seconds on April 12, 2004, Coordinated Universal Time (UTC)

    XS_DATE_TIME = /^-?\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:?\d{2})?$/

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
    self.typecasts["string"]        = lambda { |v| v.to_s }
    self.typecasts["base64Binary"]  = lambda { |v| v.unpack('m').first }

    self.available_typecasts = self.typecasts.keys

    def initialize(options, name, attributes = {})
      @options = options
      @name = Nori.hash_key(name, options)

      if converter = options[:convert_attributes_to]
        intermediate = attributes.map {|k, v| converter.call(k, v) }.flatten
        attributes = Hash[*intermediate]
      end

      @type = bare_type(attributes)

      @nil_element = false
      attributes.keys.each do |key|
        if result = nil_attribute_pattern.match(key)
          @nil_element = attributes.delete(key) == "true"
          attributes.delete("xmlns:#{result[2]}") if result[1]
        end
        attributes.delete(key) if @options[:delete_namespace_attributes] && key[/^(xmlns|xsi)/]
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
      return attribute unless @options[:convert_tags_to].respond_to? :call
      @options[:convert_tags_to].call(attribute)
    end

    def add_node(node)
      @text = true if node.is_a? String
      @children << node
    end

    # Converts the node into a hash with the node name as its single key.
    #
    # The value depends on the shape of the node. A node typed as "file"
    # becomes a {StringIOFile}, unless the +:serializable+ profile is enabled.
    # That profile returns plain data only, so a file node folds into text and
    # attributes like any other node and the base64 content is left undecoded.
    # A node with text content becomes a typecast scalar. Every other node
    # folds its children into an array or a hash. Under the +:standards+
    # profile no bare type attribute is honored ({#bare_type}), so file
    # decoding, array folding and typecasting never happen there.
    #
    # @return [Hash{String => Object}] the node name mapped to its value
    def to_hash
      return { name => file_value } if @type == "file" && !@options[:serializable]
      return { name => text_value } if @text

      groups = group_children
      value = @type == "array" ? array_value(groups) : hash_value(groups)
      value = typecast_value(value) if @type && value.nil?
      { name => value }
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

    # The value of the bare (un-namespaced) type attribute, or nil under
    # the +:standards+ profile. A recognized type is consumed from the
    # attributes because typecasting replaces it with the value it
    # describes. An unrecognized type stays visible as an ordinary
    # attribute. The bare attribute is a Rails +Hash.from_xml+ convention
    # rather than XML, so the +:standards+ profile never reads it and the
    # attribute passes through as ordinary data.
    #
    # @param attributes [Hash{String => String}] the element's attributes
    # @return [String, nil] the type name, or nil when there is none to honor
    def bare_type(attributes)
      return nil if @options[:standards]

      if self.class.available_typecasts.include?(attributes["type"])
        attributes.delete("type")
      else
        attributes["type"]
      end
    end

    # The attribute forms that declare an element nil. The prefixed form
    # is the XML Schema Instance convention (xsi:nil). The bare +nil+ form
    # is a Rails +Hash.from_xml+ convention, so the +:standards+ profile
    # only accepts the prefixed form.
    #
    # @return [Regexp] the pattern, with the prefix in capture group 2
    def nil_attribute_pattern
      @options[:standards] ? /^((.+):)nil$/ : /^((.*):)?nil$/
    end

    # Decodes the base64 content of a node typed as "file" into a
    # {StringIOFile} carrying the filename and content type attributes.
    def file_value
      file = StringIOFile.new((@children.first || '').unpack('m').first)
      file.original_filename = attributes['name'] || 'untitled'
      file.content_type = attributes['content_type'] || 'application/octet-stream'
      file
    end

    # Typecasts the text content of the node. String results are wrapped
    # so the node's attributes stay accessible on the value.
    def text_value
      value = typecast_value(inner_html)
      value = advanced_typecasting(value) if value.is_a?(String) && @options[:advanced_typecasting]
      value.is_a?(String) ? string_with_attributes(value) : value
    end

    # Groups the child nodes by their name so repeating siblings can be
    # folded into arrays.
    #
    # @return [Hash{String => Array<XMLUtilityNode>}]
    def group_children
      @children.inject({}) { |hash, child| (hash[child.name] ||= []) << child; hash }
    end

    # Collects the values of all child nodes for a node typed as "array".
    def array_value(groups)
      values = []
      groups.each do |child_name, nodes|
        if nodes.size == 1
          values << nodes.first.to_hash.entries.first.last
        else
          values << nodes.map { |node| node.to_hash[child_name] }
        end
      end
      values.flatten
    end

    # Folds the child nodes and the prefixed attributes into a hash.
    # An empty result becomes the :empty_tag_value option.
    def hash_value(groups)
      return consistent_empty_value if @options[:consistent_empty_tags] && groups.empty?

      value = {}
      groups.each do |child_name, nodes|
        if nodes.size == 1
          value.merge!(nodes.first.to_hash)
        else
          value.merge!(child_name => nodes.map { |node| node.to_hash[child_name] })
        end
      end
      value.merge!(prefixed_attributes) unless attributes.empty?
      value.empty? ? @options[:empty_tag_value] : value
    end

    # Resolves an element without children and without text when the
    # :consistent_empty_tags option is set. The element becomes the
    # :empty_tag_value option no matter which attributes it carries.
    # A string value keeps the attributes accessible on the value.
    # An explicit xsi:nil="true" wins over the option and becomes nil.
    def consistent_empty_value
      return nil if @nil_element

      value = @options[:empty_tag_value]
      value.is_a?(String) ? string_with_attributes(value) : value
    end

    # Combines a string +value+ with the node's attributes in the shape the
    # active output profile calls for.
    #
    # By default the value is a {StringWithAttributes}: a String carrying the
    # node's attributes on {StringWithAttributes#attributes}. Under the
    # +:serializable+ profile the value becomes plain, directly-serializable
    # data instead, so no custom String subclass is returned.
    #
    # @param value [String] the typecast text content of the node
    # @return [StringWithAttributes, Hash{String => String}, String] the value
    #   in the configured representation
    def string_with_attributes(value)
      return serializable_value(value) if @options[:serializable]

      string = StringWithAttributes.new(value)
      string.attributes = attributes
      string
    end

    # The +:serializable+ representation of a string +value+ and the node's
    # attributes. A node with attributes maps to the XML JSON convention
    # (+{"#text" => value}+ merged with the "@"-prefixed attributes) and a
    # node without attributes maps to the plain String. The attribute keys go
    # through the same prefixing and tag conversion as element-node attributes
    # ({#prefixed_attributes}), so every node kind shares one convention.
    #
    # @param value [String] the typecast text content of the node
    # @return [Hash{String => String}, String] the hash shape when the node
    #   has attributes, otherwise the plain +value+
    def serializable_value(value)
      return value if attributes.empty?
      { "#text" => value }.merge(prefixed_attributes)
    end

    def try_to_convert(value, &block)
      block.call(value)
    rescue ArgumentError
      value
    end

    def strip_namespace(string)
      string.split(":").last
    end
  end
end
