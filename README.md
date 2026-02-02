# <a href="https://kemalcr.com"><img src="images/kemal.png" alt="Kemal" height="50" /></a> + <a href="https://inertiajs.com"><img src="images/inertia.png" alt="Inertia" height="50" /></a>

Inertia.js adapter for Kemal written in Crystal.

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

# 1. Configure Inertia
Kemal::Inertia.configure do |config|
  config.version = "1.0"
  
  # Optional: Custom HTML handler for the first page load
  # This is useful for injecting Vite scripts/styles or custom layouts
  config.html_handler = ->(env : HTTP::Server::Context, page : String) {
    render "src/views/layout.ecr" 
  }
end

# 2. Add the middleware
add_handler Kemal::Inertia::Middleware.new

# 3. Render your pages
get "/" do |env|
  # Render 'Home' component with props
  Kemal::Inertia.render(env, "Home", 
    name: "Kemal",
    version: "1.0"
  )
end

Kemal.run
```

## Rendering

### Simple Render

Pass props as named arguments:

```crystal
get "/users" do |env|
  users = [
    {"id" => 1, "name" => "Alice"},
    {"id" => 2, "name" => "Bob"}
  ]
  
  Kemal::Inertia.render(env, "Users/Index", 
    users: users,
    count: users.size
  )
end
```

### Using a Block

Useful for complex data structures:

```crystal
get "/dashboard" do |env|
  Kemal::Inertia.render(env, "Dashboard") do
    {
      "stats" => {
        "users" => 120,
        "sales" => 42
      },
      "last_updated" => Time.local.to_s
    }
  end
end
```

## Shared Data

Shared props are automatically included in every response. Great for user sessions, flash messages, etc.

```crystal
Kemal::Inertia.share("auth") do |env|
  if id = env.session.int?("user_id")
    { "user" => { "id" => id, "name" => "Current User" } }
  else
    nil
  end
end
```

## Partial Reloads

This adapter supports Inertia's Partial Reloads feature. If a request includes `X-Inertia-Partial-Data` headers, only the requested keys will be returned.

```crystal
# Frontend request: 
# get(url, { only: ['users'], preserveState: true })

get "/users" do |env|
  # If 'users' is not requested during a partial reload, 
  # this expensive calculation might be skipped (depending on implementation optimization)
  
  Kemal::Inertia.render(env, "Users/Index",
    users: User.all, # Heavy query
    filters: params  # Light data
  )
end
```

## Examples

Check the `examples/` folder for full working examples with different frontend frameworks:

- **[React](examples/react-app)** (Vite + React)
- **[Vue](examples/vue-app)** (Vite + Vue 3)
- **[Svelte](examples/svelte-app)** (Vite + Svelte)

## Contributing

1. Fork it (<https://github.com/erayjsx/kemal-inertia/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
