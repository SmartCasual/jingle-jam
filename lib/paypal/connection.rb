module Paypal
  class Connection
    def initialize(&block)
      @connection = Faraday.new(url: ENV["PAYPAL_API_ENDPOINT"]) do |faraday|
        faraday.request :retry
        faraday.response :logger, Rails.logger, bodies: !Rails.env.production?

        block.call(faraday) if block.present?
      end
    end

    delegate :post, to: :@connection
  end
end
