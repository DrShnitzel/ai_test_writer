require "net/http"
require "uri"
require "json"

module AiTestWriter
  class AiApiClient
    OPEN_AI_URL = "https://api.openai.com/v1/chat/completions".freeze
    HEADERS = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['OPENAI_API_KEY']}"
    }.freeze

    def initialize
      raise "OPENAI_API_KEY is not set" if ENV["OPENAI_API_KEY"].nil?

      uri = URI.parse(OPEN_AI_URL)
      @http = Net::HTTP.new(uri.host, uri.port)
      @http.use_ssl = true
      @request_base = Net::HTTP::Post.new(uri.path, HEADERS)
    end

    def call(body)
      request = @request_base.dup
      request.body = body.to_json

      response = http.request(request)

      raise "Request failed #{response.code} \n\n #{response.body}" if response.code != "200"

      JSON.parse(response.body)
    end
  end
end
