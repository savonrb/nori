require "nori/version"
require "nori/core_ext"
require "nori/parser"

module Nori
  extend self

  # Translates the given +xml+ to a Hash. Accepts an optional +parser+ to use.
  def parse(xml, parser = nil)
    return {} if xml.blank?
    Parser.parse xml, parser
  end

  # Sets the +parser+ to use.
  def parser=(parser)
    Parser.use = parser
  end

  # Sets whether to use advanced typecasting.
  attr_writer :advanced_typecasting

  # Returns whether to use advanced typecasting.
  # Defaults to +true+.
  def advanced_typecasting?
    @advanced_typecasting != false
  end

  # Sets whether to strip namespaces.
  attr_writer :strip_namespaces

  # Returns whether to strip namespaces.
  # Defaults to +false+.
  def strip_namespaces?
    @strip_namespaces
  end

end
