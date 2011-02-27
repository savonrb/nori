require "nori/version"
require "nori/core_ext"
require "nori/parser"

module Nori

  def self.parse(xml)
    Parser.parse xml
  end

end
