require "nori/xml_utility_node"

module Nori
  module Parser

    # = Nori::Parser::REXML
    #
    # Parser using REXML, Ruby's standard XML library.
    # http://www.ruby-doc.org/stdlib/libdoc/rexml/rdoc/index.html
    class REXML

      def parse(xml)
        stack = []
        parser = ::REXML::Parsers::BaseParser.new(xml)

        while true
          event = parser.pull
          case event[0]
          when :end_document
            break
          when :end_doctype, :start_doctype
            # do nothing
          when :start_element
            stack.push XMLUtilityNode.new(event[1], event[2])
          when :end_element
            if stack.size > 1
              temp = stack.pop
              stack.last.add_node(temp)
            end
          when :text, :cdata
            stack.last.add_node(event[1]) unless event[1].strip.length == 0 || stack.empty?
          end
        end
        stack.length > 0 ? stack.pop.to_hash : {}
      end
    end

  end
end
