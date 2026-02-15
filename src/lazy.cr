module Kemal::Inertia
  class DeferredProp
    getter group : String
    @block : -> JSON::Any

    def initialize(group : String = "default", &block : -> _)
      @group = group
      @block = ->{ Serializer.to_any(block.call) }
    end

    def resolve : JSON::Any
      @block.call
    end
  end

  # Create a deferred prop that loads after initial render
  def self.defer(group : String = "default", &block : -> _) : DeferredProp
    DeferredProp.new(group) { block.call }
  end

  # Backward compatibility alias
  def self.lazy(&block : -> _) : DeferredProp
    DeferredProp.new("default") { block.call }
  end
end
