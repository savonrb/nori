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

  def initialize(options = {})
    defaults = {
      :strip_namespaces             => false,
      :delete_namespace_attributes  => false,
      :convert_tags_to              => nil,
      :advanced_typecasting         => true,
      :parser                       => :nokogiri
    }

    validate_options! defaults.keys, options.keys
    @options = defaults.merge(options)
  end

  def find(hash, *path)
    return hash if path.empty?

    key = path.shift
    key = self.class.hash_key(key, @options)

    return nil unless hash.include? key
    find(hash[key], *path)
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

end
