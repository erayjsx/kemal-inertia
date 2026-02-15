require "./spec_helper"

describe "Kemal::Inertia.validation_error" do
  before_each do
    Kemal::Inertia.clear_shared_props
    Kemal::Inertia.configure do |config|
      config.version = "1"
    end
  end

  it "returns 422 status with errors" do
    io = IO::Memory.new
    request = HTTP::Request.new("POST", "/users")
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    Kemal::Inertia.validation_error(context, {
      "email" => ["is required", "must be valid"],
      "name"  => ["is required"],
    })

    response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io)

    client_response.status_code.should eq(422)
    client_response.headers["Content-Type"].should eq("application/json")
    client_response.headers["X-Inertia"].should eq("true")

    json = JSON.parse(client_response.body)
    errors = json["props"]["errors"].as_h

    errors["email"].as_a.size.should eq(2)
    errors["email"].as_a[0].as_s.should eq("is required")
    errors["email"].as_a[1].as_s.should eq("must be valid")
    errors["name"].as_a.size.should eq(1)
  end

  it "includes shared props in validation error response" do
    Kemal::Inertia.share("app") do |env|
      "TestApp"
    end

    io = IO::Memory.new
    request = HTTP::Request.new("POST", "/users")
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    Kemal::Inertia.validation_error(context, {
      "email" => ["is required"],
    })

    response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io)
    json = JSON.parse(client_response.body)

    json["props"]["app"].as_s.should eq("TestApp")
    json["props"]["errors"].as_h.has_key?("email").should be_true
  end

  it "sets empty component for validation errors" do
    io = IO::Memory.new
    request = HTTP::Request.new("POST", "/users")
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    Kemal::Inertia.validation_error(context, {
      "field" => ["error"],
    })

    response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io)
    json = JSON.parse(client_response.body)

    json["component"].as_s.should eq("")
  end
end
