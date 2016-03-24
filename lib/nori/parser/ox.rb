require "ox"

class Nori
  module Parser

    # = Ox::Parser::Ox
    #
    # Ox SAX parser.
    module Ox

      class Document < ::Ox::Sax
        attr_accessor :options
        attr_accessor :element_name
        
        def stack
          @stack ||= []
        end

        def attr_stack
          @attr_stack ||= {}
        end

        def start_element(name, attrs = [])
          @element_name = name.to_s
          attr_stack.clear
        end

        # To keep backward behaviour compatibility
        # delete last child if it is a space-only text node
        def end_element(name)
          if stack.size > 1
            last = stack.pop
            maybe_string = last.children.last
            if maybe_string.is_a?(String) and maybe_string.strip.empty?
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

        alias text characters
        alias cdata characters
        
        def attr(name, str)
          attr_stack[name.to_s] = str
        end
        
        def attrs_done
          return if element_name.nil?
          stack.push Nori::XMLUtilityNode.new(options, element_name, Hash[*attr_stack.flatten])
        end
        
      end

      def self.parse(xml, options)
        document = Document.new
        document.options = options
        ::Ox.sax_parse document, xml
        document.stack.length > 0 ? document.stack.pop.to_hash : {}
      end

    end
  end
end
