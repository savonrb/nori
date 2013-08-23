class Nori
  class StringWithAttributes < String
    attr_accessor :attributes

    def initialize(value, attributes)
      super(value)
      @attributes = attributes
    end
  end
end
