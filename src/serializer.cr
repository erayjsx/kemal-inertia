require "json"

module Kemal::Inertia
  module Serializer
    def self.to_any(value) : JSON::Any
      case value
      when Nil
        JSON::Any.new(nil)
      when String
        JSON::Any.new(value)
      when Int32
        JSON::Any.new(value.to_i64)
      when Int64
        JSON::Any.new(value)
      when Float32
        JSON::Any.new(value.to_f64)
      when Float64
        JSON::Any.new(value)
      when Bool
        JSON::Any.new(value)
      when Symbol
        JSON::Any.new(value.to_s)
      when Time
        JSON::Any.new(value.to_rfc3339)
      when JSON::Any
        value
      when Array
        JSON::Any.new(value.map { |v| to_any(v) })
      when Hash
        hash = {} of String => JSON::Any
        value.each do |k, v|
          hash[k.to_s] = to_any(v)
        end
        JSON::Any.new(hash)
      else
        if value.is_a?(NamedTuple)
          hash = {} of String => JSON::Any
          value.each do |k, v|
            hash[k.to_s] = to_any(v)
          end
          JSON::Any.new(hash)
        elsif value.is_a?(Tuple)
          JSON::Any.new(value.to_a.map { |v| to_any(v) })
        elsif value.is_a?(Enum)
          JSON::Any.new(value.to_s)
        elsif value.is_a?(JSON::Serializable)
          JSON.parse(value.to_json)
        else
          # Fallback: convert to string
          JSON::Any.new(value.to_s)
        end
      end
    end
  end
end
