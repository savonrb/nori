require "date"
require "time"
require "yaml"
require "bigdecimal"

require "nori/string_with_attributes"
require "nori/string_io_file"
require "nori/type_converter"

class Nori

  # This is a slighly modified version of the XMLUtilityNode from
  # http://merb.devjavu.com/projects/merb/ticket/95 (has.sox@gmail.com)
  #
  # John Nunemaker:
  # It's mainly just adding vowels, as I ht cd wth n vwls :)
  # This represents the hard part of the work, all I did was change the
  # underlying parser.
  class XMLUtilityNode

    DEFAULT_TYPE_CONVERSIONS =  TypeConverter.new(
          'int|integer' => TypeConverter::ToInteger,
          'boolean' => TypeConverter::ToBoolean,
          'date[Tt]ime' => TypeConverter::ToTime,
          'date' => TypeConverter::ToDate,
          'decimal' => TypeConverter::ToDecimal,
          'double|float' => TypeConverter::ToFloat,
          'string' => TypeConverter::ToString,
          'base64Binary' => TypeConverter::Base64ToBinary
      )

    def initialize(options, name, attributes = {})
      @options = options
      @name = Nori.hash_key(name, options)
      @type_conversions = options[:type_conversions] || DEFAULT_TYPE_CONVERSIONS
      @nil_element = false
      @attributes = clean_attributes(attributes)
      @child_nodes = []
    end

    attr_accessor :name, :attributes, :child_nodes, :type

    def clean_attributes(attributes)
      attributes.tap do |a|
        a.keys.each do |key|
          # TODO check if this is required
          if result = /^((.*):)?nil$/.match(key)
            @nil_element = (a.delete(key) == "true")
            a.delete("xmlns:#{result[2]}") if result[1]
          end
          a.delete(key) if @options[:delete_namespace_attributes] && key.index(':')
          convert_dashed_key_to_underscore(a, key) if key.index('-')
        end
      end
    end

    # Take keys of the form foo-bar and convert them to foo_bar
    def convert_dashed_key_to_underscore(attributes, key)
      attributes[key.tr("-", "_")] = attributes.delete(key)
    end

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
      @child_nodes << node
    end

    def type
      @type ||= @type_conversions.type(attributes)
    end

    def to_hash
      conversion = @type_conversions.conversion(type)
      if conversion
        value = conversion.convert(inner_html)
        @attributes.delete(@type_conversions.namespaced_type_attribute)
      else
        if type == 'file'
          value = create_file
        elsif type == 'array'
          value = create_array
        else
          if @text
            value = @options[:advanced_typecasting] ? TypeConverter::Autodetect.convert(inner_html) : inner_html
            value = value.is_a?(String) ? StringWithAttributes.new(inner_html, attributes) : value
          else
            value = create_hash
          end
        end
      end
      return {name => value}
    end

    def create_file
      StringIOFile.new((@child_nodes.first || '').unpack('m').first).tap do |file|
        file.original_filename = attributes['name'] || 'untitled'
        file.content_type = attributes['content_type'] || 'application/octet-stream'
      end
    end

    def child_nodes_grouped
      @child_nodes.inject({}) do |node_groups, node|
        (node_groups[node.name] ||= []) << node
        node_groups
      end
    end

    def create_array
      child_nodes_grouped.collect do |group_name, nodes|
        if nodes.size == 1
          nodes.first.to_hash.entries.first.last
        else
          nodes.map{|node| node.to_hash[group_name]}
        end
      end.flatten
    end

    def create_hash
      hash = {}
      child_nodes_grouped.each do |group_name, nodes|
        if nodes.size == 1
          hash.merge!(nodes.first)
        else
          hash.merge!(group_name => nodes.map{|node| node.to_hash[group_name]})
        end
      end
      hash.merge! prefixed_attributes unless attributes.empty?
      hash.empty? ? nil : hash
    end

    # Get the inner_html of the REXML node.
    def inner_html
      @child_nodes.join
    end

    # Converts the node into a readable HTML node.
    #
    # @return <String> The HTML node in text form.
    def to_html
      attributes.merge!(:type => @type ) if @type
      "<#{name}#{attributes.to_xml_attributes}>#{@nil_element ? '' : inner_html}</#{name}>"
    end

    alias to_s to_html
  end
end
