require "nori/version"
require "nori/core_ext"
require "nori/xml_utility_node"

class Nori

  PARSERS = { :rexml => "REXML", :nokogiri => "Nokogiri" }

  def initialize(globals = {})
    defaults = {
      :strip_namespaces => false,
      :convert_tags_to  => nil
    }

    validate_options! defaults.keys, globals.keys
    @globals = defaults.merge(globals)
  end

  def parse(xml, locals = {})
    validate_xml! xml

    defaults = {
      :advanced_typecasting => true,
      :parser               => :rexml
    }

    validate_options! defaults.keys, locals.keys
    options = @globals.merge defaults.merge(locals)

    parser = load_parser options[:parser]
    parser.parse(xml, options)
  end

  private

  def load_parser(parser)
    require "nori/parser/#{parser}"
    Parser.const_get PARSERS[parser]
  end

  def validate_xml!(xml)
    return if xml.kind_of? String
    raise ArgumentError, "Expected a String to parse, got: #{xml.inspect}"
  end

  def validate_options!(available_options, options)
    spurious_options = options - available_options

    unless spurious_options.empty?
      raise ArgumentError, "Spurious options: #{spurious_options.inspect}\n" \
                           "Available options are: #{available_options.inspect}"
    end
  end

end
