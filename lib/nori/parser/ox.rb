require "ox"

class Nori
  module Parser

    # = Nori::Parser::Ox
    #
    # Ox SAX parser.
    module Ox

      class Document < ::Ox::Sax
        attr_accessor :options

        def initialize
          @elements = []
          @attrs    = {}
          @values   = {}
        end

        def stack
          @stack ||= []
        end

        def start_element(name)
          @elements << name
          stack.push Nori::XMLUtilityNode.new(options, name.to_s)
        end

        def end_element(name)
          repush_element(name) if get_attrs(name)

          if stack.size > 1
            last = stack.pop
            stack.last.add_node last
          end
        end

        def text(string)
          stack.last.add_node(string) unless string.strip.length == 0 || stack.empty?
        end

        def attr(name, str)
          set_attrs(@elements.last, [name.to_s, str])
        end

        alias cdata text

        private

        def get_attrs(name)
          @attrs[name] || []
        end

        def set_attrs(name, attrs)
          @attrs[name] ||= []
          @attrs[name] << attrs
        end

        def get_value(name)
          @values[name] || ''
        end

        def set_value(name, value)
          @values[name] = value
        end

        def repush_element(name)
          last = stack.pop

          stack.push Nori::XMLUtilityNode.new(options, name.to_s, Hash[*get_attrs(name).flatten])
          stack.last.children = last.children
          stack.last.instance_variable_set :@text, last.instance_variable_get(:@text)

          @attrs.delete(name)
        end
      end

      def self.parse(xml, options)
        document = Document.new
        document.options = options
        parser = ::Ox.sax_parse document, StringIO.new(xml)
        document.stack.length > 0 ? document.stack.pop.to_hash : {}
      end

    end
  end
end
