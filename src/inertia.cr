require "kemal"
require "html"
require "./response"
require "./config"
require "./shared"
require "./serializer"
require "./headers"
require "./lazy"

module Kemal::Inertia
  class RenderError < Exception; end

  # Render with named arguments
  def self.render(
    env : HTTP::Server::Context,
    component : String,
    **props
  )
    json_props = {} of String => JSON::Any | DeferredProp
    props.each do |key, value|
      if value.is_a?(DeferredProp)
        json_props[key.to_s] = value
      else
        json_props[key.to_s] = Serializer.to_any(value)
      end
    end

    render_raw(env, component, json_props)
  end

  # Render with block
  def self.render(
    env : HTTP::Server::Context,
    component : String,
    &block : -> Hash(String, _)
  )
    raw_props = block.call
    json_props = {} of String => JSON::Any | DeferredProp
    Serializer.to_any(raw_props).as_h.each do |k, v|
      json_props[k] = v
    end
    render_raw(env, component, json_props)
  end

  # Low-level render
  def self.render_raw(
    env : HTTP::Server::Context,
    component : String,
    props : Hash(String, JSON::Any | DeferredProp)
  )
    shared = shared_props(env)
    merged_props = {} of String => JSON::Any | DeferredProp
    shared.each { |k, v| merged_props[k] = v }
    props.each { |k, v| merged_props[k] = v }

    is_partial = env.request.headers[Headers::PARTIAL_COMPONENT]? == component

    # Partial reloads
    if is_partial
      if partial_except = env.request.headers[Headers::PARTIAL_EXCEPT]?
        except_keys = partial_except.split(",").map(&.strip)
        merged_props = merged_props.reject { |k, _| except_keys.includes?(k) }
      elsif partial_keys = env.request.headers[Headers::PARTIAL_DATA]?
        keys = partial_keys.split(",").map(&.strip)
        merged_props = merged_props.select { |k, _| keys.includes?(k) }
      end
    end

    # Resolve props and collect deferred prop groups
    resolved_props = {} of String => JSON::Any
    deferred_groups = {} of String => Array(String)

    merged_props.each do |key, value|
      case value
      when DeferredProp
        if is_partial
          # On partial reload, resolve the deferred prop
          resolved_props[key] = value.resolve
        else
          # On initial load, register in deferredProps for the client
          group = value.group
          deferred_groups[group] ||= [] of String
          deferred_groups[group] << key
        end
      when JSON::Any
        resolved_props[key] = value
      end
    end

    inertia_response = Response.new(
      component: component,
      props: resolved_props,
      url: env.request.path,
      version: Kemal::Inertia.version,
      deferred_props: deferred_groups.empty? ? nil : deferred_groups,
    )

    page_json = inertia_response.to_json

    if env.request.headers.has_key?(Headers::INERTIA)
      env.response.content_type = "application/json"
      env.response.headers[Headers::INERTIA] = "true"
      env.response.headers[Headers::VARY] = Headers::INERTIA
      env.response.print(page_json)
    else
      # Initial page load
      env.response.content_type = "text/html"

      if Kemal::Inertia.config.ssr_enabled
        if ssr_result = SSR.render(page_json)
          if handler = Kemal::Inertia.config.html_handler
            env.response.print handler.call(env, page_json)
          else
            env.response.print default_ssr_html(ssr_result[:head], ssr_result[:body])
          end
          return
        end
      end

      if handler = Kemal::Inertia.config.html_handler
        env.response.print handler.call(env, page_json)
      else
        env.response.print default_html(page_json)
      end
    end
  rescue ex
    raise RenderError.new("Failed to render Inertia component '#{component}': #{ex.message}", cause: ex)
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

  private def self.default_ssr_html(head : String, body : String)
    <<-HTML
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0" />
      #{head}
    </head>
    <body>
      #{body}
    </body>
    </html>
    HTML
  end
end
