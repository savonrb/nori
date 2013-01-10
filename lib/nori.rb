require "nori/version"
require "nori/core_ext"
require "nori/xml_utility_node"

class Nori

  PARSERS = { :rexml => "REXML", :nokogiri => "Nokogiri" }

  def initialize(options = {})
    defaults = {
      :strip_namespaces     => false,
      :convert_tags_to      => nil,
      :advanced_typecasting => true,
      :parser               => :nokogiri
    }

    validate_options! defaults.keys, options.keys
    @options = defaults.merge(options)
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
