module Kemal::Inertia
  # Share CSRF token automatically via shared props.
  # Requires Kemal session to be configured.
  def self.share_csrf_token
    share("csrf_token") do |env|
      env.session.string?("csrf") || ""
    end
  end
end
