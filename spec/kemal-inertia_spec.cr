require "./spec_helper"

describe Kemal::Inertia do
  it "renders JSON for Inertia requests" do
    io = IO::Memory.new
    request = HTTP::Request.new("GET", "/", headers: HTTP::Headers{"X-Inertia" => "true"})
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    Kemal::Inertia.render(context, "Home", foo: "bar")

    response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io)

    client_response.headers["X-Inertia"].should eq("true")
    client_response.headers["Content-Type"].should eq("application/json")

    json = JSON.parse(client_response.body)
    json["component"].as_s.should eq("Home")
    json["props"]["foo"].as_s.should eq("bar")
    json["url"].as_s.should eq("/")
  end

  it "renders HTML for first visit" do
    io = IO::Memory.new
    request = HTTP::Request.new("GET", "/")
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    Kemal::Inertia.render(context, "Home", foo: "bar")

    response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io)

    client_response.headers["Content-Type"].should eq("text/html")
    client_response.body.should contain("<div id=\"app\"")
    client_response.body.should contain("data-page=")
  end

  it "handles partial reloads" do
    io = IO::Memory.new
    headers = HTTP::Headers{
      "X-Inertia" => "true",
      "X-Inertia-Partial-Component" => "Home",
      "X-Inertia-Partial-Data" => "foo"
    }
    request = HTTP::Request.new("GET", "/", headers: headers)
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    Kemal::Inertia.render(context, "Home", foo: "bar", baz: "qux")

    response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io)
    json = JSON.parse(client_response.body)

    json["props"].as_h.has_key?("foo").should be_true
    json["props"].as_h.has_key?("baz").should be_false
  end

  it "returns all props if partial component does not match" do
    io = IO::Memory.new
    headers = HTTP::Headers{
      "X-Inertia" => "true",
      "X-Inertia-Partial-Component" => "Other",
      "X-Inertia-Partial-Data" => "foo"
    }
    request = HTTP::Request.new("GET", "/", headers: headers)
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    Kemal::Inertia.render(context, "Home", foo: "bar", baz: "qux")

    response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io)
    json = JSON.parse(client_response.body)

    json["props"].as_h.has_key?("foo").should be_true
    json["props"].as_h.has_key?("baz").should be_true
  end
end
