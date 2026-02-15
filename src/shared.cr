require "json"

module Kemal::Inertia
  @@shared_props = {} of String => Proc(HTTP::Server::Context, JSON::Any)

  def self.share(key : String, &block : HTTP::Server::Context -> _)
    @@shared_props[key] = ->(env : HTTP::Server::Context) {
      Serializer.to_any(block.call(env))
    }
  end

  def self.shared_props(env : HTTP::Server::Context)
    props = {} of String => JSON::Any
    @@shared_props.each do |key, block|
      props[key] = block.call(env)
    end
    props
  end

  def self.clear_shared_props
    @@shared_props.clear
  end
end
