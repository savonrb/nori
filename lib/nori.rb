require "nori/version"
require "nori/core_ext"
require "nori/xml_utility_node"

class Nori

  def self.hash_key(name, options = {})
    name = name.tr("-", "_")
    name = name.split(":").last if options[:strip_namespaces]
    name = options[:convert_tags_to].call(name) if options[:convert_tags_to].respond_to? :call
    name
  end

  PARSERS = { :rexml => "REXML", :nokogiri => "Nokogiri" }

  DEFAULT_TYPE_CONVERTER =  TypeConverter.new(
      'int|integer' => TypeConverter::ToInteger,
      'boolean' => TypeConverter::ToBoolean,
      'date[Tt]ime' => TypeConverter::ToTime,
      'date' => TypeConverter::ToDate,
      'decimal' => TypeConverter::ToDecimal,
      'double|float' => TypeConverter::ToFloat,
      'string' => TypeConverter::ToString,
      'base64Binary' => TypeConverter::Base64ToBinary
  )

  def initialize(options = {})
    defaults = {
      :strip_namespaces             => false,
      :delete_namespace_attributes  => false,
      :convert_tags_to              => nil,
      :advanced_typecasting         => true,
      :type_converter               => DEFAULT_TYPE_CONVERTER,
      :parser                       => :nokogiri
    }

    validate_options! defaults.keys, options.keys
    @options = defaults.merge(options)
  end

  def find(hash, *path)
    return hash if path.empty?

    key = path.shift
    key = self.class.hash_key(key, @options)

    value = find_value(hash, key)
    find(value, *path) if value
  end

  def parse(xml)
    cleaned_xml = xml.strip
    return {} if cleaned_xml.empty?

    parser = load_parser @options[:parser]
    parser.parse(cleaned_xml, @options)
  end

  private

  def load_parser(parser)
    require "nori/parser/#{parser}"
    Parser.const_get PARSERS[parser]
  end

  def validate_options!(available_options, options)
    spurious_options = options - available_options

    unless spurious_options.empty?
      raise ArgumentError, "Spurious options: #{spurious_options.inspect}\n" \
                           "Available options are: #{available_options.inspect}"
    end
  end

  def find_value(hash, key)
    hash.each do |k, v|
      key_without_namespace = k.to_s.split(':').last
      return v if key_without_namespace == key.to_s
    end

    nil
  end

end
