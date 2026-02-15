require "./spec_helper"

# Simple handler that sets a flag to confirm it was called
class TestNextHandler
  include HTTP::Handler

  getter called : Bool = false

  def call(context : HTTP::Server::Context)
    @called = true
    context.response.print("OK")
  end
end

describe Kemal::Inertia::Middleware do
  before_each do
    Kemal::Inertia.configure do |config|
      config.version = "1.0"
    end
  end

  it "passes through non-Inertia requests" do
    middleware = Kemal::Inertia::Middleware.new
    next_handler = TestNextHandler.new
    middleware.next = next_handler

    io = IO::Memory.new
    request = HTTP::Request.new("GET", "/")
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    middleware.call(context)
    next_handler.called.should be_true
  end

  it "passes through when versions match" do
    middleware = Kemal::Inertia::Middleware.new
    next_handler = TestNextHandler.new
    middleware.next = next_handler

    io = IO::Memory.new
    headers = HTTP::Headers{
      "X-Inertia"         => "true",
      "X-Inertia-Version" => "1.0",
    }
    request = HTTP::Request.new("GET", "/", headers: headers)
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    middleware.call(context)
    next_handler.called.should be_true
  end

  it "returns 409 when versions mismatch" do
    middleware = Kemal::Inertia::Middleware.new
    next_handler = TestNextHandler.new
    middleware.next = next_handler

    io = IO::Memory.new
    headers = HTTP::Headers{
      "X-Inertia"         => "true",
      "X-Inertia-Version" => "old-version",
    }
    request = HTTP::Request.new("GET", "/dashboard", headers: headers)
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    middleware.call(context)

    context.response.status_code.should eq(409)
    context.response.headers["X-Inertia-Location"].should eq("/dashboard")
    next_handler.called.should be_false
  end

  it "passes through when no X-Inertia-Version header" do
    middleware = Kemal::Inertia::Middleware.new
    next_handler = TestNextHandler.new
    middleware.next = next_handler

    io = IO::Memory.new
    headers = HTTP::Headers{
      "X-Inertia" => "true",
    }
    request = HTTP::Request.new("GET", "/", headers: headers)
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    middleware.call(context)
    next_handler.called.should be_true
  end
end
