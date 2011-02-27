require "nori/parser/rexml"

module Nori

  # = Nori::Parser
  #
  # Manages the parser classes. Currently supports:
  #
  # * REXML
  module Parser

    # The default parser.
    DEFAULT = :rexml

    # Returns the parser to use. Defaults to <tt>Nori::Parser::REXML</tt>.
    def self.use
      @use ||= DEFAULT
    end

    # Sets the +parser+ to use. Raises an +ArgumentError+ unless the +parser+ exists.
    def self.use=(parser)
      validate_parser! parser
      @use = parser
    end

    # Returns a memoized +Hash+ of parsers.
    def self.parsers
      @parsers ||= {
        :rexml => { :class => REXML, :require => "rexml/document" }
      }
    end

    # Returns a +parser+. Raises an +ArgumentError+ unless the +parser+ exists.
    def self.find(parser)
      validate_parser! parser
      load_parser parser
    end

  private

    # Raises an +ArgumentError+ unless the +parser+ exists.
    def self.validate_parser!(parser)
      raise ArgumentError, "Invalid Nori parser: #{parser}" unless parsers[parser]
    end

    # Tries to load and return the given +parser+.
    def self.load_parser(parser)
      require parsers[parser][:require]
      parsers[parser][:class]
    end

  end
end
