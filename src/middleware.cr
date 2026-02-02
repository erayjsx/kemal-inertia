require "kemal"

module Kemal::Inertia
  class Middleware
    include HTTP::Handler

    def call(context : HTTP::Server::Context)
      is_inertia = context.request.headers.has_key?("X-Inertia")

      # Version kontrolü (request başında)
      if is_inertia
        request_version = context.request.headers["X-Inertia-Version"]?
        current_version = Kemal::Inertia.version

        if request_version && current_version && request_version != current_version
          context.response.status_code = 409
          context.response.headers["X-Inertia-Location"] = context.request.path
          return
        end
      end

      call_next(context)
    end
  end
end
