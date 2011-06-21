require "nori/version"
require "nori/core_ext"
require "nori/parser"
require "nori/xml_utility_node"

module Nori

  # Translates the given +xml+ to a Hash. Accepts an optional +parser+ to use.
  def self.parse(xml, parser = nil)
    return {} if xml.blank?
    Parser.parse xml, parser
  end

  # Sets the +parser+ to use.
  def self.parser=(parser)
    Parser.use = parser
  end

end
