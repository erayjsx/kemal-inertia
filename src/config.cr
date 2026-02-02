require "json"

module Kemal::Inertia
  class Config
    property version : String = "1"
    # The handler used to render HTML for the first page load (non-Inertia requests).
    # It receives (context, page_json) and should return the full HTML string.
    property html_handler : Proc(HTTP::Server::Context, String, String)?
  end

  @@config = Config.new

  def self.config
    @@config
  end

  def self.configure
    yield @@config
  end

  # Deprecated: backward compatibility
  def self.version=(value : String)
    @@config.version = value
  end

  def self.version
    @@config.version
  end
end
