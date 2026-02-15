require "kemal"
require "./headers"

module Kemal::Inertia
  class Middleware
    include HTTP::Handler

    def call(context : HTTP::Server::Context)
      is_inertia = context.request.headers.has_key?(Headers::INERTIA)

      # Version check at request start
      if is_inertia
        request_version = context.request.headers[Headers::VERSION]?
        current_version = Kemal::Inertia.version

        if request_version && current_version && request_version != current_version
          context.response.status_code = 409
          context.response.headers[Headers::LOCATION] = context.request.path
          return
        end
      end

      call_next(context)
    end
  end
end
