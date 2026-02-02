require "kemal"
require "kemal-inertia"
require "json"

# Load manifest if it exists
MANIFEST = if File.exists?("public/dist/manifest.json")
             JSON.parse(File.read("public/dist/manifest.json"))
           else
             nil
           end

# Helper to generate script tags
def vite_tags(entry : String)
  if Kemal.config.env == "production"
    manifest = MANIFEST
    if manifest && manifest[entry]?
      entry_data = manifest[entry]
      file = entry_data["file"].as_s
      tags = String.build do |str|
        str << %(<script type="module" src="/dist/#{file}"></script>)
        if entry_data["css"]?
          entry_data["css"].as_a.each do |css|
            str << %(<link rel="stylesheet" href="/dist/#{css.as_s}">)
          end
        end
      end
      return tags
    end
  end

  # Default to Dev (Vite Server)
  return <<-HTML
    <script type="module" src="http://localhost:5173/@vite/client"></script>
    <script type="module" src="http://localhost:5173/#{entry}"></script>
  HTML
end

# Setup Inertia configuration
Kemal::Inertia.configure do |config|
  config.version = "1.0"
  config.html_handler = ->(env : HTTP::Server::Context, page : String) {
    render "src/views/layout.ecr"
  }
end

# Add Inertia middleware
add_handler Kemal::Inertia::Middleware.new

serve_static({"gzip" => true, "dir_listing" => false})

get "/" do |env|
  Kemal::Inertia.render(env, "Home", name: "Inertia + Vue")
end

Kemal.run
