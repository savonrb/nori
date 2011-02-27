require "nori/version"
require "nori/core_ext"
require "nori/parser"

module Nori

  def self.parse(xml)
    adapter = Parser.find Parser.use
    adapter.new.parse xml
  end

end
