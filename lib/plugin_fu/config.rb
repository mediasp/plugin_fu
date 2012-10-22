# -*- coding: utf-8 -*-
class PluginFu::Config

  # raised when there is something a miss with config values
  class ValueError < RuntimeError ; end

  class TypeError < ValueError
    def initialize(defn, value)
      super("Could not coerce #{value.inspect} to type #{defn.type} for #{defn.key}")
    end
  end

  class UnexpectedValueError < ValueError
    def initialize(*keys)
      super("did not expect values for: #{keys.flatten.join(', ')}")
    end
  end

  class RequiredValueError < ValueError
    def initialize(*keys)
      super("missing required values for: #{keys.flatten.join(', ')}")
    end
  end


  def initialize(definitions, values, allow_missing=false)
    @definitions = definitions
    @raw_values  = values
    @allow_missing = allow_missing

    validate!
  end

  def to_hash
    @values.clone
  end

  def [](key)
    @values[key]
  end

  private

  def validate!
    extra = @raw_values.select {|k, v| @definitions.none? {|d| d.key == k } }
    raise UnexpectedValueError, extra.map(&:first) if extra.any?

    missing = @definitions.
      select {|d| d.required? && @raw_values.none? {|k, v| k == d.key } }
    raise RequiredValueError, missing.map(&:first) if !@allow_missing && missing.any?

    paired = @raw_values.map {|k, v| [@definitions.find {|d| d.key == k }, v] }
    coerced = Hash[*paired.map {|d, v| [d.key, d.coerce(v)] }.flatten]

    backing = Hash.new do |hash, key|
      coerced[key] || @definitions.find {|d| d.key == key }.default(hash)
    end

    defaults =
      Hash[*@definitions.map {|d| [d.key, d.default(backing)] }.flatten]

    @values = defaults.merge(coerced)
  end

  # DSL Helper for receiving method calls to define new config entries
  class Receiver

    TYPES = [:string, :float, :integer, :decimal, :boolean]

    def initialize
      @defined = []
    end

    def method_missing(method, *args, &block)
      raise "bad type: #{method}" unless TYPES.include?(method)
      key, description, options = args
      definition = Definition.new(method, key, description, options)
      @defined << definition
    end

    def all ; @defined ; end
  end

  class Definition

    attr_reader :type
    attr_reader :key
    attr_reader :description

    def initialize(type, key, description, options)
      @type = type
      @key = key
      @description = description
      @options = options || {}
    end

    REAL = /^([\-\+])?[0-9]*(\.[0-9]*)?$/
    INTEGER = /^[\+\-]?[0-9]*$/
    BOOLEAN = /(true)|(false)/

    def coerce(value)
      return nil if value.nil?

      value = value.to_s

      case type
      when :string then value
      when :float
        REAL.match(value) or raise TypeError.new(self, value)
        value.to_f
      when :decimal
        REAL.match(value) or raise TypeError.new(self, value)
        BigDecimal.new(value)
      when :integer
        INTEGER.match(value) or raise TypeError.new(self, value)
        value.to_i
      when :boolean
        BOOLEAN.match(value) or raise TypeError.new(self, value)
        value == "true" ? true : false
      else
        raise ArgumentError, "don't know how to coerce #{type}"
      end
    end

    def default(config_hash)
      default = @options[:default]

      value =
        if default.is_a? Proc
          default.call(config_hash)
        else
          default
        end

      coerce(value)
    end

    def required? ; @options[:required] ; end
    def default_value ; @options[:default] ; end
  end


end
