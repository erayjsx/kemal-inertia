require "kemal"

module Kemal::Inertia
  def self.redirect(
    env : HTTP::Server::Context,
    location : String
  )
    env.response.status_code = 303
    env.response.headers["Location"] = location

    # Inertia request ise header ekle
    if env.request.headers.has_key?("X-Inertia")
      env.response.headers["X-Inertia"] = "true"
    end
  end
end
