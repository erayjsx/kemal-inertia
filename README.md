# <a href="https://kemalcr.com" target="_blank">Kemal</a> + <a href="https://inertiajs.com" target="_blank">Inertia</a>

Inertia.js v2 adapter for Kemal written in Crystal.

This shard allows you to use Inertia.js with Kemal, enabling modern SPA-like applications using Vue, React, or Svelte without building a separate API.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     kemal:
       github: kemalcr/kemal
     kemal-inertia:
       github: erayjsx/kemal-inertia
   ```

2. Run `shards install`

## Basic Setup

```crystal
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
  Kemal::Inertia.render(env, "home", name: "Kemal", version: "1.0")
end

Kemal.run
```

## Rendering

### Simple Render

```crystal
get "/users" do |env|
  users = [
    {"id" => 1, "name" => "Alice"},
    {"id" => 2, "name" => "Bob"},
  ]

  Kemal::Inertia.render(env, "users/index", users: users, count: users.size)
end
```

### Using a Block

```crystal
get "/dashboard" do |env|
  Kemal::Inertia.render(env, "dashboard") do
    {
      "stats"        => {"users" => 120, "sales" => 42},
      "last_updated" => Time.local.to_s,
    }
  end
end
```

## Shared Data

Shared props are automatically included in every response.

```crystal
Kemal::Inertia.share("auth") do |env|
  if id = env.session.int?("user_id")
    {"user" => {"id" => id, "name" => "Current User"}}
  else
    nil
  end
end
```

## Deferred Props

Deferred props are excluded from the initial page load and fetched in a separate request afterwards. You can group them to control parallel fetching.

```crystal
get "/users" do |env|
  Kemal::Inertia.render(env, "users/index",
    users: User.all,
    permissions: Kemal::Inertia.defer { Permission.all },
    teams: Kemal::Inertia.defer("sidebar") { Team.all },
    projects: Kemal::Inertia.defer("sidebar") { Project.all },
  )
end
```

## Partial Reloads

If a request includes `X-Inertia-Partial-Data` or `X-Inertia-Partial-Except` headers, only the requested (or non-excluded) props will be returned.

```crystal
get "/users" do |env|
  Kemal::Inertia.render(env, "users/index",
    users: User.all,
    filters: params,
  )
end
```

## Validation Errors

```crystal
post "/users" do |env|
  errors = {} of String => Array(String)
  errors["email"] = ["is required"] if email.empty?

  unless errors.empty?
    Kemal::Inertia.validation_error(env, errors)
    next
  end

  Kemal::Inertia.redirect(env, "/users")
end
```

## Redirects

```crystal
Kemal::Inertia.redirect(env, "/dashboard")
```

## SSR

```crystal
Kemal::Inertia.configure do |config|
  config.ssr_enabled = true
  config.ssr_url = "http://localhost:13714"
end
```

## Examples

Check the `examples/` folder for full working examples:

- **[React](examples/react-app)** (Vite + React 19)
- **[Vue](examples/vue-app)** (Vite + Vue 3)
- **[Svelte](examples/svelte-app)** (Vite + Svelte 5)

## Contributing

1. Fork it (<https://github.com/erayjsx/kemal-inertia/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
