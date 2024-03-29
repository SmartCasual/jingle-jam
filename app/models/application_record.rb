class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :where_money, -> (monies) {
    conditions = monies.each_with_object({}) { |(field_prefix, money), hash|
      hash["#{field_prefix}_decimals"] = money.cents
      hash["#{field_prefix}_currency"] = money.currency.iso_code
    }

    where(**conditions)
  }

  class << self
  private

    def monetize(attribute, **kwargs)
      super("#{attribute}_decimals", **kwargs)

      define_method "human_#{attribute}=" do |value|
        self.send("#{attribute}=", Monetize.parse(value, send("#{attribute}_currency")))
      end

      define_method("human_#{attribute}") do |symbol: false|
        send(attribute)&.format(no_cents_if_whole: true, symbol:)
      end
    end

    def skip_uniqueness_validation(attributes)
      filter = _validate_callbacks.find { |c|
        c.filter.is_a?(ActiveRecord::Validations::UniquenessValidator) &&
          c.filter.attributes == Array(attributes)
      }.filter

      skip_callback(:validate, :before, filter)
    end
  end
end
