require "English"

require_relative "bearer_token"
require_relative "connection"

module Paypal
  class API
    class << self
      def create_order(params)
        post("/v2/checkout/orders", params)[:id]
      end

      def capture_payment_for_order(order_id)
        post("/v2/checkout/orders/#{order_id}/capture")
      end

      def reset_connection
        @connection = nil
        @bearer_token = nil
      end

    private

      def post(path, params = {})
        response = connection.post(path, params).body

        response = JSON.parse(response) if response.is_a?(String)
        response.deep_symbolize_keys!

        raise response[:error_description] if response.has_key?(:error_description)

        response
      rescue JSON::ParserError, Faraday::ClientError => e
        Rails.logger.error(["#{self.class} - #{e.class}: #{e.message}", e.backtrace].join($INPUT_RECORD_SEPARATOR))
        head :unprocessable_entity
      end

      def connection
        @connection ||= Paypal::Connection.new do |faraday|
          faraday.request :json
          faraday.response :json

          faraday.request :authorization, "Bearer", bearer_token
        end
      end

      def bearer_token
        return @bearer_token if @bearer_token && !@bearer_token.expired?

        @bearer_token = Paypal::BearerToken.new
      end
    end
  end
end
