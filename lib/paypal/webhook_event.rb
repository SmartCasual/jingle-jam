require "x509_certificate"

module Paypal
  class WebhookEvent
    VALID_PAYPAL_CERT_CN = "messageverificationcerts.paypal.com".freeze
    VALID_PAYPAL_CERT_HOST = "api.paypal.com".freeze

    class << self
      def cert_cache
        @cert_cache ||= {}
      end

      def clear_cert_cache
        @cert_cache = nil
      end
    end

    def initialize(params:, request:)
      @headers = request.headers
      @body = request.body&.read
      @params = params
    end

    def verify!
      raise WebhookEventVerificationFailed unless verify
    end

    def verify
      verify_cert_url && verify_cert && verify_signature
    end

    def data
      @data ||= @params.deep_symbolize_keys
    end

  private

    def verify_signature
      cert.verify(
        algorithm:,
        signature:,
        fingerprint:,
      ).tap do |result|
        Rails.logger.debug("Bad signature") unless result
      end
    end

    def verify_cert
      verify_common_name && verify_date
    end

    def verify_common_name
      (cert.common_name == VALID_PAYPAL_CERT_CN).tap do |result|
        unless result
          Rails.logger.debug {
            "Incorrect common name #{cert.common_name} (expected #{VALID_PAYPAL_CERT_CN})"
          }
        end
      end
    end

    def verify_date
      cert.in_date?.tap do |result|
        Rails.logger.debug("Not in date") unless result
      end
    end

    def verify_cert_url
      return false if cert_url.blank?

      verify_cert_url_scheme && verify_cert_url_host
    end

    def verify_cert_url_scheme
      (cert_url.scheme == "https").tap do |result|
        Rails.logger.debug { "#{cert_url.scheme} is not HTTPS" } unless result
      end
    end

    def verify_cert_url_host
      (cert_url.host == VALID_PAYPAL_CERT_HOST).tap do |result|
        unless result
          Rails.logger.debug {
            "Incorrect cert URL host #{cert_url.host} (expected #{VALID_PAYPAL_CERT_HOST})"
          }
        end
      end
    end

    def algorithm
      case (algo = @headers["PAYPAL-AUTH-ALGO"])
      when "SHA256withRSA" then "SHA256"
      else
        algo
      end
    end

    def signature
      @headers["PAYPAL-AUTH-SIGNATURE"]
    end

    def cert_url
      @cert_url ||= URI.parse(@headers.fetch("PAYPAL-CERT-URL")) if @headers.to_h.has_key?("PAYPAL-CERT-URL")
    end

    def cert
      self.class.cert_cache[cert_url.to_s] ||= X509Certificate.new(cert_url.open.read)
    end

    # https://developer.paypal.com/api/rest/webhooks/#link-eventheadervalidation
    def fingerprint
      [
        @headers["PAYPAL-TRANSMISSION-ID"],
        @headers["PAYPAL-TRANSMISSION-TIME"],
        ENV.fetch("PAYPAL_WEBHOOK_ID"),
        Zlib.crc32(@body),
      ].join("|")
    end
  end

  class WebhookEventVerificationFailed < StandardError; end
end
