module Nori

  # = Nori::Parser
  #
  # Manages the parser classes. Currently supports:
  #
  # * REXML
  # * Nokogiri
  module Parser

    # The default parser.
    DEFAULT = :rexml

    # List of available parsers.
    PARSERS = { :rexml => "REXML", :nokogiri => "Nokogiri" }

    # Returns the parser to use. Defaults to <tt>Nori::Parser::REXML</tt>.
    def self.use
      @use ||= DEFAULT
    end

    # Sets the +parser+ to use. Raises an +ArgumentError+ unless the +parser+ exists.
    def self.use=(parser)
      validate_parser! parser
      @use = parser
    end

    # Returns the parsed +xml+ using the parser to use. Raises an +ArgumentError+
    # unless the optional or default +parser+ exists.
    def self.parse(xml, parser = nil, nori = Nori)
      load_parser(parser).parse(xml, nori)
    end

  private

    # Raises an +ArgumentError+ unless the +parser+ exists.
    def self.validate_parser!(parser)
      raise ArgumentError, "Invalid Nori parser: #{parser}" unless PARSERS[parser]
    end

    # Requires and returns the +parser+ to use.
    def self.load_parser(parser)
      parser ||= use
      validate_parser! parser

      require "nori/parser/#{parser}"
      const_get PARSERS[parser]
    end

  end
end
