module Nori
  module CoreExt
    module String

      def snake_case
        return self.downcase if self =~ /^[A-Z]+$/
        self.gsub(/([A-Z]+)(?=[A-Z][a-z]?)|\B[A-Z]/, '_\&') =~ /_*(.*)/
        $+.downcase
      end unless method_defined?(:snake_case)

    end
  end
end

String.send :include, Nori::CoreExt::String
