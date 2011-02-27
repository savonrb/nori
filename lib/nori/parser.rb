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
      raise ArgumentError, "Invalid Nori parser: #{parser}" unless parsers[parser]
      @use = parser
    end

    # Returns a memoized +Hash+ of parsers.
    def self.parsers
      @parsers ||= {
        :rexml => { :class => REXML, :require => "rexml/document" }
      }
    end

    # Returns the parsed +xml+ using the parser to use.
    def self.parse(xml)
      load_parser.new.parse xml
    end

  private

    # Requires and returns the +parser+ to use.
    def self.load_parser
      require parsers[use][:require]
      parsers[use][:class]
    end

  end
end
