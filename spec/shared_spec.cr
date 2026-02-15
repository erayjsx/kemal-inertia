require "./spec_helper"

describe "Kemal::Inertia shared props" do
  before_each do
    Kemal::Inertia.clear_shared_props
  end

  it "shares a single prop" do
    Kemal::Inertia.share("app_name") do |env|
      "MyApp"
    end

    io = IO::Memory.new
    request = HTTP::Request.new("GET", "/")
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    props = Kemal::Inertia.shared_props(context)
    props["app_name"].as_s.should eq("MyApp")
  end

  it "shares multiple props" do
    Kemal::Inertia.share("app_name") do |env|
      "MyApp"
    end

    Kemal::Inertia.share("version") do |env|
      "2.0"
    end

    io = IO::Memory.new
    request = HTTP::Request.new("GET", "/")
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    props = Kemal::Inertia.shared_props(context)
    props.size.should eq(2)
    props["app_name"].as_s.should eq("MyApp")
    props["version"].as_s.should eq("2.0")
  end

  it "overrides shared prop with same key" do
    Kemal::Inertia.share("name") do |env|
      "first"
    end

    Kemal::Inertia.share("name") do |env|
      "second"
    end

    io = IO::Memory.new
    request = HTTP::Request.new("GET", "/")
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    props = Kemal::Inertia.shared_props(context)
    props["name"].as_s.should eq("second")
  end

  it "includes shared props in rendered response" do
    Kemal::Inertia.clear_shared_props
    Kemal::Inertia.configure do |config|
      config.version = "1"
      config.ssr_enabled = false
      config.html_handler = nil
    end

    Kemal::Inertia.share("global") do |env|
      "shared_value"
    end

    io = IO::Memory.new
    request = HTTP::Request.new("GET", "/", headers: HTTP::Headers{"X-Inertia" => "true"})
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    Kemal::Inertia.render(context, "Page", local: "prop")

    response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io)
    json = JSON.parse(client_response.body)

    json["props"]["global"].as_s.should eq("shared_value")
    json["props"]["local"].as_s.should eq("prop")
  end

  it "clears shared props" do
    Kemal::Inertia.share("test") do |env|
      "value"
    end

    Kemal::Inertia.clear_shared_props

    io = IO::Memory.new
    request = HTTP::Request.new("GET", "/")
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    props = Kemal::Inertia.shared_props(context)
    props.size.should eq(0)
  end
end
