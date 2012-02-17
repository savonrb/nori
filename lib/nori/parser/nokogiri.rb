require "nokogiri"

module Nori
  module Parser

    # = Nori::Parser::Nokogiri
    #
    # Nokogiri SAX parser.
    module Nokogiri

      class Document < ::Nokogiri::XML::SAX::Document
        attr_accessor :nori

        def stack
          @stack ||= []
        end

        def start_element(name, attrs = [])
          stack.push Nori::XMLUtilityNode.new(nori, name, Hash[*attrs.flatten])
        end

        def end_element(name)
          if stack.size > 1
            last = stack.pop
            stack.last.add_node last
          end
        end

        def characters(string)
          stack.last.add_node(string) unless string.strip.length == 0 || stack.empty?
        end

        alias cdata_block characters

      end

      def self.parse(xml, nori)
        return {} if xml.strip.empty?

        document = Document.new
        document.nori = nori
        parser = ::Nokogiri::XML::SAX::Parser.new document
        parser.parse xml
        document.stack.length > 0 ? document.stack.pop.to_hash : {}
      end

    end
  end
end
