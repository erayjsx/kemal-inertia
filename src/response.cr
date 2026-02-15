require "json"

module Kemal::Inertia
  struct Response
    include JSON::Serializable

    getter component : String
    getter props : Hash(String, JSON::Any)
    getter url : String
    getter version : String?

    @[JSON::Field(key: "deferredProps", emit_null: false)]
    getter deferred_props : Hash(String, Array(String))?

    @[JSON::Field(key: "mergeProps", emit_null: false)]
    getter merge_props : Array(String)?

    @[JSON::Field(key: "encryptHistory", emit_null: false)]
    getter encrypt_history : Bool?

    @[JSON::Field(key: "clearHistory", emit_null: false)]
    getter clear_history : Bool?

    def initialize(
      @component : String,
      @props : Hash(String, JSON::Any),
      @url : String,
      @version : String? = nil,
      @deferred_props : Hash(String, Array(String))? = nil,
      @merge_props : Array(String)? = nil,
      @encrypt_history : Bool? = nil,
      @clear_history : Bool? = nil
    )
    end
  end
end
