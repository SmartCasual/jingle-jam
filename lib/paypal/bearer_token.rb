require_relative "connection"

module Paypal
  class BearerToken
    def expired?
      return false if expires_at.nil?

      Time.zone.now > (expires_at - 60.seconds)
    end

    def to_s
      token
    end

  private

    def token
      response[:access_token]
    end

    def expires_at
      response[:expires_in]&.seconds&.from_now
    end

    def response
      @response ||= connection.post("/v1/oauth2/token", grant_type: "client_credentials").body.tap do |body|
        body.deep_symbolize_keys!

        raise body[:message] if body[:name] == "Bad Request"
        raise body[:error_description] if body.has_key?(:error_description)
      end
    end

    def connection
      @connection ||= Paypal::Connection.new do |faraday|
        faraday.request :authorization, :basic, ENV["PAYPAL_CLIENT_ID"], ENV["PAYPAL_SECRET"]

        faraday.request :url_encoded
        faraday.response :json
      end
    end
  end
end
