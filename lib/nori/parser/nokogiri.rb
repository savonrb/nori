require "nokogiri"

class Nori
  module Parser

    # = Nori::Parser::Nokogiri
    #
    # Nokogiri SAX parser.
    module Nokogiri

      class Document < ::Nokogiri::XML::SAX::Document
        # Marks a text node that came from a CDATA section so the whitespace
        # stripping in {#end_element} and {#characters} leaves it alone.
        # A CDATA section is the author's explicit literal-data marker
        # (XML 1.0 §2.7), so its content is real even when it is only
        # whitespace and is never trimmed. The marker never reaches the
        # output because {XMLUtilityNode#inner_html} joins children into
        # a plain string.
        class CDataText < ::String; end

        attr_accessor :options

        def stack
          @stack ||= []
        end

        def start_element(name, attrs = [])
          stack.push Nori::XMLUtilityNode.new(options, name, Hash[*attrs.flatten])
        end

        # To keep backward behaviour compatibility
        # delete last child if it is a space-only text node.
        # CDATA content is literal and is never stripped.
        def end_element(name)
          if stack.size > 1
            last = stack.pop
            maybe_string = last.children.last
            if maybe_string.is_a?(String) and !maybe_string.is_a?(CDataText) and maybe_string.strip.empty?
              last.children.pop
            end
            stack.last.add_node last
          end
        end

        # If this node is a successive character then add it as is.
        # First child being a space-only text node will not be added
        # because there is no previous characters.
        def characters(string)
          last = stack.last
          if last and last.children.last.is_a?(String) or string.strip.size > 0
            last.add_node(string)
          end
        end

        # Adds the CDATA section content verbatim.
        def cdata_block(string)
          last = stack.last
          last.add_node(CDataText.new(string)) if last
        end

      end

      def self.parse(xml, options)
        document = Document.new
        document.options = options
        parser = ::Nokogiri::XML::SAX::Parser.new document
        parser.parse xml
        document.stack.length > 0 ? document.stack.pop.to_hash : {}
      end

    end
  end
end
