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

    @[JSON::Field(key: "initialDeferredProps", emit_null: false)]
    getter initial_deferred_props : Hash(String, Array(String))?

    @[JSON::Field(key: "mergeProps", emit_null: false)]
    getter merge_props : Array(String)?

    @[JSON::Field(key: "prependProps", emit_null: false)]
    getter prepend_props : Array(String)?

    @[JSON::Field(key: "deepMergeProps", emit_null: false)]
    getter deep_merge_props : Array(String)?

    @[JSON::Field(key: "matchPropsOn", emit_null: false)]
    getter match_props_on : Array(String)?

    @[JSON::Field(key: "encryptHistory", emit_null: false)]
    getter encrypt_history : Bool?

    @[JSON::Field(key: "clearHistory", emit_null: false)]
    getter clear_history : Bool?

    @[JSON::Field(key: "flash", emit_null: false)]
    getter flash : Hash(String, JSON::Any)?

    @[JSON::Field(key: "onceProps", emit_null: false)]
    getter once_props : Hash(String, JSON::Any)?

    @[JSON::Field(key: "scrollProps", emit_null: false)]
    getter scroll_props : Hash(String, JSON::Any)?

    @[JSON::Field(key: "sharedProps", emit_null: false)]
    getter shared_props : Array(String)?

    @[JSON::Field(key: "preserveFragment", emit_null: false)]
    getter preserve_fragment : Bool?

    def initialize(
      @component : String,
      @props : Hash(String, JSON::Any),
      @url : String,
      @version : String? = nil,
      @deferred_props : Hash(String, Array(String))? = nil,
      @initial_deferred_props : Hash(String, Array(String))? = nil,
      @merge_props : Array(String)? = nil,
      @prepend_props : Array(String)? = nil,
      @deep_merge_props : Array(String)? = nil,
      @match_props_on : Array(String)? = nil,
      @encrypt_history : Bool? = nil,
      @clear_history : Bool? = nil,
      @flash : Hash(String, JSON::Any)? = nil,
      @once_props : Hash(String, JSON::Any)? = nil,
      @scroll_props : Hash(String, JSON::Any)? = nil,
      @shared_props : Array(String)? = nil,
      @preserve_fragment : Bool? = nil
    )
    end
  end
end
