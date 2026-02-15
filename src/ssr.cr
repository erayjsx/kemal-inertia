require "http/client"
require "json"

module Kemal::Inertia
  module SSR
    def self.render(page_json : String) : NamedTuple(head: String, body: String)?
      return nil unless Kemal::Inertia.config.ssr_enabled

      uri = URI.parse(Kemal::Inertia.config.ssr_url)
      client = HTTP::Client.new(uri)
      client.connect_timeout = 3.seconds
      client.read_timeout = 5.seconds

      response = client.post(
        "/render",
        headers: HTTP::Headers{"Content-Type" => "application/json"},
        body: page_json
      )

      if response.success?
        json = JSON.parse(response.body)
        head = json["head"].as_a.map(&.as_s).join("\n")
        body = json["body"].as_s
        {head: head, body: body}
      else
        nil
      end
    rescue
      nil
    end
  end
end
