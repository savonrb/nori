require "nori/version"
require "nori/core_ext"
require "nori/parser"
require "nori/xml_utility_node"

module Nori
  extend self

  # Translates the given +xml+ to a Hash. Accepts an optional +parser+ to use.
  def parse(xml, parser = nil)
    return {} if xml.blank?
    Parser.parse xml, parser, self
  end

  # Sets the +parser+ to use.
  def parser=(parser)
    Parser.use = parser
  end

  # Yields +self+ for configuration.
  def configure
    yield self
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

  # Expects a +block+ which receives a tag to convert.
  # Accepts +nil+ for a reset to the default behavior of not converting tags.
  def convert_tags_to(reset = nil, &block)
    @convert_tag = reset || block
  end

  # Transforms a given +tag+ using the specified conversion formula.
  def convert_tag(tag)
    @convert_tag.call(tag)
  end

  # Returns whether to convert tags.
  def convert_tags?
    @convert_tag
  end

end
