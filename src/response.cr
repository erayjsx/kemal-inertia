require "json"

module Kemal::Inertia
  struct Response
    include JSON::Serializable

    getter component : String
    getter props : Hash(String, JSON::Any)
    getter url : String
    getter version : String?

    def initialize(
      @component : String,
      @props : Hash(String, JSON::Any),
      @url : String,
      @version : String? = nil
    )
    end
  end
end
