require "kemal"
require "kemal-inertia"

Kemal::Inertia.configure do |config|
  config.version = "1.0"
  config.html_handler = ->(env : HTTP::Server::Context, page : String) {
    render "src/views/layout.ecr"
  }
end

add_handler Kemal::Inertia::Middleware.new

get "/" do |env|
  Kemal::Inertia.render(env, "home", name: "Inertia + Svelte")
end

Kemal.run
