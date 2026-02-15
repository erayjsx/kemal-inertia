require "kemal"
require "./headers"

module Kemal::Inertia
  def self.redirect(
    env : HTTP::Server::Context,
    location : String
  )
    env.response.status_code = 303
    env.response.headers["Location"] = location

    # Add header if Inertia request
    if env.request.headers.has_key?(Headers::INERTIA)
      env.response.headers[Headers::INERTIA] = "true"
    end
  end
end
