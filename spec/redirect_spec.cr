require "./spec_helper"

describe "Kemal::Inertia.redirect" do
  it "returns 303 status with Location header" do
    io = IO::Memory.new
    request = HTTP::Request.new("POST", "/users")
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    Kemal::Inertia.redirect(context, "/dashboard")

    context.response.status_code.should eq(303)
    context.response.headers["Location"].should eq("/dashboard")
  end

  it "adds X-Inertia header for Inertia requests" do
    io = IO::Memory.new
    request = HTTP::Request.new("POST", "/users", headers: HTTP::Headers{"X-Inertia" => "true"})
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    Kemal::Inertia.redirect(context, "/dashboard")

    context.response.status_code.should eq(303)
    context.response.headers["Location"].should eq("/dashboard")
    context.response.headers["X-Inertia"].should eq("true")
  end

  it "does not add X-Inertia header for non-Inertia requests" do
    io = IO::Memory.new
    request = HTTP::Request.new("POST", "/users")
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    Kemal::Inertia.redirect(context, "/dashboard")

    context.response.headers.has_key?("X-Inertia").should be_false
  end
end
