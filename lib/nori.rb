require "nori/version"
require "nori/core_ext"
require "nori/xml_utility_node"

class Nori

  def self.hash_key(name, options = {})
    name = name.tr("-", "_") if options[:convert_dashes_to_underscores]
    name = name.split(":").last if options[:strip_namespaces]
    name = options[:convert_tags_to].call(name) if options[:convert_tags_to].respond_to? :call
    name
  end

  PARSERS = { :rexml => "REXML", :nokogiri => "Nokogiri" }

  def initialize(options = {})
    defaults = {
      :strip_namespaces              => false,
      :delete_namespace_attributes   => false,
      :convert_tags_to               => nil,
      :convert_attributes_to         => nil,
      :empty_tag_value               => nil,
      :consistent_empty_tags         => false,
      :advanced_typecasting          => true,
      :convert_dashes_to_underscores => true,
      :scrub_xml                     => true,
      :standards                     => false,
      :serializable                  => false,
      :parser                        => :nokogiri
    }

    validate_options! defaults.keys, options.keys
    @options = defaults.merge(standards_defaults(options)).merge(options)
  end

  def find(hash, *path)
    return hash if path.empty?

    key = path.shift
    key = self.class.hash_key(key, @options)

    value = find_value(hash, key)
    find(value, *path) if value
  end

  def parse(xml)
    cleaned_xml = scrub_xml(xml).strip
    return {} if cleaned_xml.empty?

    parser = load_parser @options[:parser]
    parser.parse(cleaned_xml, @options)
  end

  private

  # The defaults implied by the +:standards+ profile.
  #
  # The profile groups the spec-correct behaviors under a single opt-in.
  # It turns on the XML string-value model for empty elements
  # (+:consistent_empty_tags+ with an empty-string +:empty_tag_value+) and,
  # in the parsers, xml:space honoring. These are defaults, so an explicit
  # +:consistent_empty_tags+ or +:empty_tag_value+ passed by the caller
  # still wins. When the profile is off the hash is empty and parsing is
  # unchanged.
  #
  # @param options [Hash] the options passed to {#initialize}
  # @return [Hash] the implied defaults, or +{}+ when the profile is off
  def standards_defaults(options)
    return {} unless options[:standards]
    { :consistent_empty_tags => true, :empty_tag_value => "" }
  end

  def load_parser(parser)
    require "nori/parser/#{parser}"
    Parser.const_get PARSERS[parser]
  end

  # Expects a +block+ which receives a tag to convert.
  # Accepts +nil+ for a reset to the default behavior of not converting tags.
  def convert_tags_to(reset = nil, &block)
    @convert_tag = reset || block
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

  def scrub_xml(string)
    if @options[:scrub_xml]
      if string.respond_to? :scrub
        string.scrub
      else
        if string.valid_encoding?
          string
        else
          enc = string.encoding
          mid_enc = (["UTF-8", "UTF-16BE"].map { |e| Encoding.find(e) } - [enc]).first
          string.encode(mid_enc, undef: :replace, invalid: :replace).encode(enc)
        end
      end
    else
      string 
    end
  end

end
