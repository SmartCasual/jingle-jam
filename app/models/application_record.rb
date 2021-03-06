class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :where_money, -> (monies) {
    where(**monies.each_with_object({}) { |(field_prefix, money), hash|
      hash["#{field_prefix}_decimals"] = money.cents
      hash["#{field_prefix}_currency"] = money.currency.iso_code
    })
  }

  class << self
  private

    def monetize(attribute, **kwargs)
      super("#{attribute}_decimals", **kwargs)

      attr_writer "human_#{attribute}"

      before_validation do
        human_val = instance_variable_get("@human_#{attribute}")
        self.send("#{attribute}=", Monetize.parse(human_val, send(:price_currency))) if human_val.present?
      end

      define_method("human_#{attribute}") do |symbol: false|
        send(attribute)&.format(no_cents_if_whole: true, symbol: symbol)
      end
    end
  end
end
