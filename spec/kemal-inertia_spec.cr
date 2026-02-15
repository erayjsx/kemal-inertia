require "./spec_helper"

describe Kemal::Inertia do
  before_each do
    Kemal::Inertia.clear_shared_props
    Kemal::Inertia.configure do |config|
      config.version = "1"
      config.ssr_enabled = false
      config.html_handler = nil
    end
  end

  describe ".render with named arguments" do
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
      client_response.headers["Vary"].should eq("X-Inertia")

      json = JSON.parse(client_response.body)
      json["component"].as_s.should eq("Home")
      json["props"]["foo"].as_s.should eq("bar")
      json["url"].as_s.should eq("/")
      json["version"].as_s.should eq("1")
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

    it "renders multiple prop types" do
      io = IO::Memory.new
      request = HTTP::Request.new("GET", "/", headers: HTTP::Headers{"X-Inertia" => "true"})
      response = HTTP::Server::Response.new(io)
      context = HTTP::Server::Context.new(request, response)

      Kemal::Inertia.render(context, "Page",
        name: "test",
        count: 42,
        active: true,
        score: 3.14
      )

      response.close
      io.rewind
      client_response = HTTP::Client::Response.from_io(io)
      json = JSON.parse(client_response.body)

      json["props"]["name"].as_s.should eq("test")
      json["props"]["count"].as_i.should eq(42)
      json["props"]["active"].as_bool.should be_true
      json["props"]["score"].as_f.should be_close(3.14, 0.001)
    end
  end

  describe ".render with block" do
    it "renders props from a block" do
      io = IO::Memory.new
      request = HTTP::Request.new("GET", "/", headers: HTTP::Headers{"X-Inertia" => "true"})
      response = HTTP::Server::Response.new(io)
      context = HTTP::Server::Context.new(request, response)

      Kemal::Inertia.render(context, "Dashboard") do
        {"users" => 10, "title" => "Dashboard"}
      end

      response.close
      io.rewind
      client_response = HTTP::Client::Response.from_io(io)
      json = JSON.parse(client_response.body)

      json["component"].as_s.should eq("Dashboard")
      json["props"]["users"].as_i.should eq(10)
      json["props"]["title"].as_s.should eq("Dashboard")
    end
  end

  describe "partial reloads" do
    it "handles partial reloads with X-Inertia-Partial-Data" do
      io = IO::Memory.new
      headers = HTTP::Headers{
        "X-Inertia"                   => "true",
        "X-Inertia-Partial-Component" => "Home",
        "X-Inertia-Partial-Data"      => "foo",
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
        "X-Inertia"                   => "true",
        "X-Inertia-Partial-Component" => "Other",
        "X-Inertia-Partial-Data"      => "foo",
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

    it "handles X-Inertia-Partial-Except" do
      io = IO::Memory.new
      headers = HTTP::Headers{
        "X-Inertia"                   => "true",
        "X-Inertia-Partial-Component" => "Home",
        "X-Inertia-Partial-Except"    => "baz",
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

    it "Partial-Except takes precedence over Partial-Data" do
      io = IO::Memory.new
      headers = HTTP::Headers{
        "X-Inertia"                   => "true",
        "X-Inertia-Partial-Component" => "Home",
        "X-Inertia-Partial-Data"      => "foo",
        "X-Inertia-Partial-Except"    => "baz",
      }
      request = HTTP::Request.new("GET", "/", headers: headers)
      response = HTTP::Server::Response.new(io)
      context = HTTP::Server::Context.new(request, response)

      Kemal::Inertia.render(context, "Home", foo: "bar", baz: "qux", extra: "val")

      response.close
      io.rewind
      client_response = HTTP::Client::Response.from_io(io)
      json = JSON.parse(client_response.body)

      json["props"].as_h.has_key?("foo").should be_true
      json["props"].as_h.has_key?("extra").should be_true
      json["props"].as_h.has_key?("baz").should be_false
    end
  end

  describe "custom html_handler" do
    it "uses custom html_handler for initial page load" do
      Kemal::Inertia.configure do |config|
        config.html_handler = ->(env : HTTP::Server::Context, page : String) {
          "<html><body><div id=\"custom\">#{page}</div></body></html>"
        }
      end

      io = IO::Memory.new
      request = HTTP::Request.new("GET", "/")
      response = HTTP::Server::Response.new(io)
      context = HTTP::Server::Context.new(request, response)

      Kemal::Inertia.render(context, "Home", foo: "bar")

      response.close
      io.rewind
      client_response = HTTP::Client::Response.from_io(io)

      client_response.body.should contain("<div id=\"custom\">")
    end
  end
end
