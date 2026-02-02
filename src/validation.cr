require "json"

module Kemal::Inertia
  def self.validation_error(
    env : HTTP::Server::Context,
    errors : Hash(String, Array(String))
  )
    error_props = {} of String => JSON::Any

    errors.each do |field, messages|
      json_messages = messages.map { |m| JSON::Any.new(m) }
      error_props[field] = JSON::Any.new(json_messages)
    end

    props = {
      "errors" => JSON::Any.new(error_props)
    }

    inertia_response = Response.new(
      component: "",
      props: shared_props(env).merge(props),
      url: env.request.path,
      version: Kemal::Inertia.version
    )

    env.response.status_code = 422
    env.response.content_type = "application/json"
    env.response.headers["X-Inertia"] = "true"
    env.response.print(inertia_response.to_json)
  end
end
