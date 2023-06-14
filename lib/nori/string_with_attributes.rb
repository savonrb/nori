class Nori
  class StringWithAttributes < String

    attr_accessor :attributes

    def as_json
      to_s
    end

  end
end
