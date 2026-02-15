require "./spec_helper"

describe Kemal::Inertia::Config do
  before_each do
    Kemal::Inertia.configure do |config|
      config.version = "1"
      config.ssr_enabled = false
      config.ssr_url = "http://localhost:13714"
      config.html_handler = nil
    end
  end

  it "has default version" do
    config = Kemal::Inertia::Config.new
    config.version.should eq("1")
  end

  it "has default ssr_enabled as false" do
    config = Kemal::Inertia::Config.new
    config.ssr_enabled.should be_false
  end

  it "has default ssr_url" do
    config = Kemal::Inertia::Config.new
    config.ssr_url.should eq("http://localhost:13714")
  end

  it "has default html_handler as nil" do
    config = Kemal::Inertia::Config.new
    config.html_handler.should be_nil
  end

  it "allows setting version via configure block" do
    Kemal::Inertia.configure do |config|
      config.version = "2.0"
    end
    Kemal::Inertia.version.should eq("2.0")
  end

  it "allows setting version via deprecated setter" do
    Kemal::Inertia.version = "3.0"
    Kemal::Inertia.version.should eq("3.0")
  end

  it "allows enabling SSR" do
    Kemal::Inertia.configure do |config|
      config.ssr_enabled = true
      config.ssr_url = "http://localhost:3000"
    end
    Kemal::Inertia.config.ssr_enabled.should be_true
    Kemal::Inertia.config.ssr_url.should eq("http://localhost:3000")
  end

  it "allows setting custom html_handler" do
    handler = ->(env : HTTP::Server::Context, page : String) { "<html>#{page}</html>" }
    Kemal::Inertia.configure do |config|
      config.html_handler = handler
    end
    Kemal::Inertia.config.html_handler.should_not be_nil
  end
end
