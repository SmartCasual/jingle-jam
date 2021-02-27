class Currency
  SYMBOL_MAP = {
    "GBP" => "£",
    "USD" => "$",
    "EUR" => "€",
    "AUD" => "$",
    "CAD" => "$",
  }.freeze

  SUPPORTED_CURRENCIES = SYMBOL_MAP.keys.freeze
  SUPPORTED_CURRENCY_SYMBOLS = SYMBOL_MAP.values.uniq.freeze

  DEFAULT_CURRENCY = "GBP".freeze

  class << self
    def present_all
      SYMBOL_MAP.each.with_object({}) do |(iso_code, symbol), hash|
        hash["#{iso_code} (#{symbol})"] = iso_code.downcase
      end
    end

    def supported?(iso_code)
      SUPPORTED_CURRENCIES.include?(iso_code.upcase)
    end
  end
end
