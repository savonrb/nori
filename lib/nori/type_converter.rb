require 'rexml/document'

class Nori
  class TypeConverter
    attr_accessor :attribute_prefix, :type_attribute_name, :type_prefix, :conversions

    def initialize(conversions = {})
      @attribute_prefix = nil
      @type_attribute_name = 'type'
      @type_prefix = nil
      @conversions = conversions
    end

    def namespaced_type_attribute
      @namespaced_type_attribute ||= @attribute_prefix.nil? ? @type_attribute_name : "#{@attribute_prefix}:#{@type_attribute_name}"
    end

    def conversion(type)
      if !type.nil? && type_namespace_matches?(type)
        stripped_type = strip_namespace(type)
        @conversions.each_pair do |type_pattern, type_converter|
          if (stripped_type =~ /^#{type_pattern}$/)
            return type_converter
          end
        end
      end
      return nil
    end

    def type(attributes)
      attributes[namespaced_type_attribute]
    end

    def type_namespace_matches?(type)
      @type_prefix.nil? && type.index(':').nil? || type.index(@type_prefix + ":") == 0
    end

    def strip_namespace(type)
      @type_prefix.nil? ? type : type.gsub(/^#{@type_prefix}:/, '')
    end

    def detect_namespace_prefixes!(xml, opts = {})
      root_node = REXML::Document.new(xml).root
      if root_node
        namespaces = root_node.namespaces
        @attribute_prefix = namespaces.key(opts[:attribute_namespace] || XmlNamespace::XML_SCHEMA_INSTANCE)
        @type_prefix = namespaces.key(opts[:type_namespace] || XmlNamespace::XML_SCHEMA)
      end
    end

    module XmlNamespace
      XML_SCHEMA = 'http://www.w3.org/2001/XMLSchema'
      XML_SCHEMA_INSTANCE = 'http://www.w3.org/2001/XMLSchema-instance'
    end

    # -- Type Converter

    class NoConvert
      def self.convert(value)
        value
      end
    end

    class ToInteger
      def self.convert(value)
        (value.nil? || value.length == 0) ? nil : value.to_i
      end
    end

    class ToFloat
      def self.convert(value)
        (value.nil? || value.length == 0) ? nil : value.to_f
      end
    end

    class ToBoolean
      TRUE_VALUES = ['true', '1', 'yes', 'on', 't']
      FALSE_VALUES = ['false', '0', 'no', 'off', 'f']

      def self.convert(value)
        return true if TRUE_VALUES.include? value.strip
        return false if FALSE_VALUES.include? value.strip
        return nil
      end
    end

    class ToDecimal
      def self.convert(value)
        (value.nil? || value.length == 0) ? nil : BigDecimal(value.to_s)
      end
    end

    class ToTime
      def self.convert(value)
        (value.nil? || value.length == 0) ? nil : Time.parse(value).utc
      end
    end

    class ToDate
      def self.convert(value)
        (value.nil? || value.length == 0) ? nil : Date.parse(value)
      end
    end

    class ToString
      def self.convert(value)
        value.nil? ? nil : value.to_s
      end
    end

    class Base64ToBinary
      def self.convert(value)
        (value.nil? || value.length == 0) ? nil : value.unpack('m').first
      end
    end

    class Autodetect

      # Simple xs:time Regexp.
      # Valid xs:time formats
      # 13:20:00          1:20 PM
      # 13:20:30.5555     1:20 PM and 30.5555 seconds
      # 13:20:00-05:00    1:20 PM, US Eastern Standard Time
      # 13:20:00+02:00    1:20 PM, Central European Standard Time
      # 13:20:00Z         1:20 PM, Coordinated Universal Time (UTC)
      # 00:00:00          midnight
      # 24:00:00          midnight

      XS_TIME = /^\d{2}:\d{2}:\d{2}[Z\.\-\+]?\d*:?\d*$/

      # Simple xs:date Regexp.
      # Valid xs:date formats
      # 2004-04-12           April 12, 2004
      # -0045-01-01          January 1, 45 BC
      # 12004-04-12          April 12, 12004
      # 2004-04-12-05:00     April 12, 2004, US Eastern Standard Time, which is 5 hours behind Coordinated Universal Time (UTC)
      # 2004-04-12+02:00     April 12, 2004, Central European Summer Time, which is 2 hours ahead of Coordinated Universal Time (UTC)
      # 2004-04-12Z          April 12, 2004, Coordinated Universal Time (UTC)

      XS_DATE = /^[-]?\d{4}-\d{2}-\d{2}[Z\-\+]?\d*:?\d*$/

      # Simple xs:dateTime Regexp.
      # Valid xs:dateTime formats
      # 2004-04-12T13:20:00           1:20 pm on April 12, 2004
      # 2004-04-12T13:20:15.5         1:20 pm and 15.5 seconds on April 12, 2004
      # 2004-04-12T13:20:00-05:00     1:20 pm on April 12, 2004, US Eastern Standard Time
      # 2004-04-12T13:20:00+02:00     1:20 pm on April 12, 2004, Central European Summer Time
      # 2004-04-12T13:20:15.5-05:00   1:20 pm and 15.5 seconds on April 12, 2004, US Eastern Standard Time
      # 2004-04-12T13:20:00Z          1:20 pm on April 12, 2004, Coordinated Universal Time (UTC)

      XS_DATE_TIME = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\.Z]?\d*[\-\+]?\d*:?\d*$/

      def self.convert(value)
        split = value.split
        return value if split.size > 1

        case split.first
          when "true" then
            true
          when "false" then
            false
          when XS_DATE_TIME then
            try_to_convert(value) { |x| DateTime.parse(x) }
          when XS_DATE then
            try_to_convert(value) { |x| Date.parse(x) }
          when XS_TIME then
            try_to_convert(value) { |x| Time.parse(x) }
          else
            value
        end
      end

      def self.try_to_convert(value, &block)
        block.call(value)
      rescue ArgumentError
        value
      end
    end
  end
end
