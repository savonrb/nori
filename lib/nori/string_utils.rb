class Nori
  module StringUtils
    # Converts a string to snake case.
    #
    # @param inputstring [String] The string to be converted to snake case.
    # @return [String] A copy of the input string converted to snake case.
    def self.snakecase(inputstring)
      str = inputstring.dup
      str.gsub!(/::/, '/')
      str.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      str.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      str.tr!(".", "_")
      str.tr!("-", "_")
      str.downcase!
      str
    end
  end
end
