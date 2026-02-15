require "./spec_helper"

describe "Kemal::Inertia deferred props" do
  before_each do
    Kemal::Inertia.clear_shared_props
    Kemal::Inertia.configure do |config|
      config.version = "1"
      config.ssr_enabled = false
      config.html_handler = nil
    end
  end

  it "excludes deferred props from initial props and adds deferredProps to page object" do
    io = IO::Memory.new
    request = HTTP::Request.new("GET", "/", headers: HTTP::Headers{"X-Inertia" => "true"})
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    deferred = Kemal::Inertia.defer { "expensive_data" }
    Kemal::Inertia.render(context, "home", eager: "yes", slow: deferred)

    response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io)
    json = JSON.parse(client_response.body)

    json["props"]["eager"].as_s.should eq("yes")
    json["props"].as_h.has_key?("slow").should be_false
    json["deferredProps"]["default"].as_a.map(&.as_s).should contain("slow")
  end

  it "groups deferred props by group name" do
    io = IO::Memory.new
    request = HTTP::Request.new("GET", "/", headers: HTTP::Headers{"X-Inertia" => "true"})
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    prop_a = Kemal::Inertia.defer("sidebar") { "a" }
    prop_b = Kemal::Inertia.defer("sidebar") { "b" }
    prop_c = Kemal::Inertia.defer { "c" }

    Kemal::Inertia.render(context, "page", x: prop_a, y: prop_b, z: prop_c)

    response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io)
    json = JSON.parse(client_response.body)

    sidebar = json["deferredProps"]["sidebar"].as_a.map(&.as_s)
    sidebar.should contain("x")
    sidebar.should contain("y")
    json["deferredProps"]["default"].as_a.map(&.as_s).should contain("z")
  end

  it "resolves deferred props on partial reload" do
    io = IO::Memory.new
    headers = HTTP::Headers{
      "X-Inertia"                   => "true",
      "X-Inertia-Partial-Component" => "home",
      "X-Inertia-Partial-Data"      => "slow",
    }
    request = HTTP::Request.new("GET", "/", headers: headers)
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    deferred = Kemal::Inertia.defer { "expensive_data" }
    Kemal::Inertia.render(context, "home", eager: "yes", slow: deferred)

    response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io)
    json = JSON.parse(client_response.body)

    json["props"]["slow"].as_s.should eq("expensive_data")
    json["props"].as_h.has_key?("eager").should be_false
  end

  it "backward compatible lazy alias works" do
    io = IO::Memory.new
    request = HTTP::Request.new("GET", "/", headers: HTTP::Headers{"X-Inertia" => "true"})
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    lazy_prop = Kemal::Inertia.lazy { "lazy_data" }
    Kemal::Inertia.render(context, "page", data: lazy_prop)

    response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io)
    json = JSON.parse(client_response.body)

    json["props"].as_h.has_key?("data").should be_false
    json["deferredProps"]["default"].as_a.map(&.as_s).should contain("data")
  end

  it "resolves deferred prop with correct value" do
    counter = 0
    deferred = Kemal::Inertia.defer {
      counter += 1
      counter
    }

    io = IO::Memory.new
    headers = HTTP::Headers{
      "X-Inertia"                   => "true",
      "X-Inertia-Partial-Component" => "page",
      "X-Inertia-Partial-Data"      => "count",
    }
    request = HTTP::Request.new("GET", "/", headers: headers)
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    Kemal::Inertia.render(context, "page", count: deferred)

    response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io)
    json = JSON.parse(client_response.body)

    json["props"]["count"].as_i64.should eq(1)
  end

  it "does not include deferredProps when there are none" do
    io = IO::Memory.new
    request = HTTP::Request.new("GET", "/", headers: HTTP::Headers{"X-Inertia" => "true"})
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    Kemal::Inertia.render(context, "page", name: "test")

    response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io)
    json = JSON.parse(client_response.body)

    json.as_h.has_key?("deferredProps").should be_false
  end
end
