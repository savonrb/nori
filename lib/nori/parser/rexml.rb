require "rexml/parsers/baseparser"
require "rexml/text"
require "rexml/document"

class Nori
  module Parser

    # = Nori::Parser::REXML
    #
    # REXML pull parser.
    module REXML

      def self.parse(xml, options)
        stack = []
        # Tracks the xml:space value in effect for each open element so
        # whitespace-only text can be kept under xml:space="preserve".
        space_stack = []
        parser = ::REXML::Parsers::BaseParser.new(xml)

        while true
          raw_data = parser.pull
          event = unnormalize(raw_data)
          case event[0]
          when :end_document
            break
          when :end_doctype, :start_doctype
            # do nothing
          when :start_element
            space_stack.push xml_space(event[2], space_stack)
            stack.push Nori::XMLUtilityNode.new(options, event[1], event[2])
          when :end_element
            space_stack.pop
            if stack.size > 1
              temp = stack.pop
              stack.last.add_node(temp)
            end
          when :text
            # Whitespace-only text is insignificant and stripped, unless
            # xml:space="preserve" is in effect under the :standards profile.
            keep = preserve_whitespace?(options, space_stack) || event[1].strip.length > 0
            stack.last.add_node(event[1]) if keep && !stack.empty?
          when :cdata
            # CDATA is the author's explicit literal-data marker (XML 1.0 §2.7),
            # so whitespace-only CDATA is kept rather than stripped like text.
            stack.last.add_node(raw_data[1]) unless stack.empty?
          end
        end
        stack.length > 0 ? stack.pop.to_hash : {}
      end

      # The xml:space value for an element: its own declaration if it has
      # one, otherwise the value inherited from the nearest ancestor.
      # Defaults to "default". See XML 1.0 §2.10.
      #
      # @param attributes [Hash{String => String}] the element's attributes
      # @param space_stack [Array<String>] the ancestor xml:space values
      # @return [String] "preserve", "default", or an inherited value
      def self.xml_space(attributes, space_stack)
        (attributes && attributes["xml:space"]) || space_stack.last || "default"
      end

      # Whether whitespace-only text must be kept for the current element.
      # Only the +:standards+ profile honors xml:space.
      #
      # @return [Boolean]
      def self.preserve_whitespace?(options, space_stack)
        options[:standards] && space_stack.last == "preserve"
      end

      def self.unnormalize(event)
        event.map do |el|
          if el.is_a?(String)
            ::REXML::Text.unnormalize(el)
          elsif el.is_a?(Hash)
            el.each {|k,v| el[k] = ::REXML::Text.unnormalize(v)}
          else
            el
          end
        end
      end
    end
  end
end
