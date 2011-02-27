require "nori/version"
require "nori/core_ext"
require "nori/parser"

module Nori

  # Translates the given +xml+ to a Hash. Accepts an optional +parser+ to use.
  def self.parse(xml, parser = nil)
    return {} if xml.blank?
    Parser.parse xml, parser
  end

end