# kemal-inertia

Inertia.js adapter for Kemal written in Crystal.

This shard allows you to use Inertia.js with Kemal, enabling modern
SPA-like applications using Vue, React, or Svelte without building an API.

---

## Installation

Add this shard to your `shard.yml`:

```yaml
dependencies:
  kemal-inertia:
    github: YOUR_GITHUB_USERNAME/kemal-inertia
Then install:
shards install
Basic Setup
require "kemal"
require "kemal-inertia"

Kemal::Inertia.version = "1"
Kemal.config.add_handler Kemal::Inertia::Middleware.new
Rendering Pages
Simple render
get "/users" do |env|
  Inertia.render env, "Users/Index",
    users: User.all,
    count: User.count
end
Using a block
get "/dashboard" do |env|
  Inertia.render env, "Dashboard" do
    {
      stats: {
        users: 120,
        sales: 42
      }
    }
  end
end
Shared Props
Shared props are automatically included in every response.
Kemal::Inertia.share("auth") do |env|
  if id = env.session.int?("user_id")
    { id: id }
  else
    nil
  end
end

Kemal::Inertia.share("flash") do |env|
  {
    success: env.session.string?("flash_success"),
    error: env.session.string?("flash_error")
  }
end
Frontend usage:
props.auth
props.flash.success
Redirects
Use Inertia.redirect instead of env.redirect:
post "/login" do |env|
  Inertia.redirect env, "/dashboard"
end
Redirects use HTTP 303 and are fully Inertia-compatible.
Validation Errors (422)
post "/login" do |env|
  errors = {} of String => Array(String)

  errors["email"] = ["Email is required"]
  errors["password"] = ["Password too short"]

  unless errors.empty?
    Inertia.validation_error env, errors
    next
  end

  Inertia.redirect env, "/dashboard"
end
Frontend:
props.errors.email[0]
Versioning
Inertia uses asset versioning to force full reloads when assets change.
Kemal::Inertia.version = "1"
If the frontend version differs, a 409 Conflict response is returned
with X-Inertia-Location.
Roadmap
 Partial reloads (only, except)
 Lazy props
 File uploads
 Improved type serializers
 Documentation site