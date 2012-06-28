module Nori
  module CoreExt
    module Object

      def xml_attributes
        @xml_attributes ||= {}
      end

      attr_writer :xml_attributes

      def blank?
        respond_to?(:empty?) ? empty? : !self
      end unless method_defined?(:blank?)

    end
  end
end

Object.send :include, Nori::CoreExt::Object
