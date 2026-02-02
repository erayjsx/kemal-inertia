require "kemal"
require "html"
require "./response"
require "./config"
require "./shared"
require "./serializer"

module Kemal::Inertia
  # Hash ile kullanım
  def self.render(
    env : HTTP::Server::Context,
    component : String,
    **props
  )
    json_props = {} of String => JSON::Any
    props.each do |key, value|
      json_props[key.to_s] = Serializer.to_any(value)
    end

    render_raw(env, component, json_props)
  end

  # Block ile kullanım
  def self.render(
    env : HTTP::Server::Context,
    component : String,
    &block : -> Hash
  )
    raw_props = block.call
    json_props = Serializer.to_any(raw_props).as_h
    render_raw(env, component, json_props)
  end

  # Eski düşük seviye render
  def self.render_raw(
    env : HTTP::Server::Context,
    component : String,
    props : Hash(String, JSON::Any)
  )
    merged_props = shared_props(env).merge(props)

    # Partial Reloads
    if env.request.headers["X-Inertia-Partial-Component"]? == component
      if partial_keys = env.request.headers["X-Inertia-Partial-Data"]?
        keys = partial_keys.split(",").map { |k| k.strip }
        merged_props = merged_props.select { |k, _| keys.includes?(k) }
      end
    end

    inertia_response = Response.new(
      component: component,
      props: merged_props,
      url: env.request.path,
      version: Kemal::Inertia.version
    )

    page_json = inertia_response.to_json

    if env.request.headers.has_key?("X-Inertia")
      env.response.content_type = "application/json"
      env.response.headers["X-Inertia"] = "true"
      env.response.print(page_json)
    else
      # Initial page load
      env.response.content_type = "text/html"
      if handler = Kemal::Inertia.config.html_handler
        env.response.print handler.call(env, page_json)
      else
        env.response.print default_html(page_json)
      end
    end
  end

  private def self.default_html(page_json : String)
    <<-HTML
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0" />
      <title>Inertia App</title>
    </head>
    <body>
      <div id="app" data-page='#{HTML.escape(page_json)}'></div>
    </body>
    </html>
    HTML
  end
end
