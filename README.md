# <a href="https://kemalcr.com" target="_blank">Kemal</a> + <a href="https://inertiajs.com" target="_blank">Inertia</a>

Inertia.js v3 adapter for Kemal written in Crystal.

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
  Kemal::Inertia.render(env, "home", name: "Kemal")
end

Kemal.run
```

Your `layout.ecr` should use the v3 script tag format:

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0" />
    <title>My App</title>
  </head>
  <body>
    <div id="app"></div>
    <script id="app" type="application/json"><%= page %></script>
  </body>
</html>
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

Shared props are automatically included in every response. Their keys are also listed in the `sharedProps` field of the page object (v3).

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

Use `Kemal::Inertia.optional` (v3) or `Kemal::Inertia.defer`:

```crystal
get "/users" do |env|
  Kemal::Inertia.render(env, "users/index",
    users: User.all,
    permissions: Kemal::Inertia.optional { Permission.all },
    teams: Kemal::Inertia.optional("sidebar") { Team.all },
    projects: Kemal::Inertia.optional("sidebar") { Project.all },
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

- **[React](examples/react-app)** (Vite + React 19 + @inertiajs/react v3)
- **[Vue](examples/vue-app)** (Vite + Vue 3 + @inertiajs/vue3 v3)
- **[Svelte](examples/svelte-app)** (Vite + Svelte 5 + @inertiajs/svelte v3)

## Contributing

1. Fork it (<https://github.com/erayjsx/kemal-inertia/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
