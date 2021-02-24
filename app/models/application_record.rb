class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :where_money, -> (monies) {
    where(**monies.each_with_object({}) { |(field_prefix, money), hash|
      hash["#{field_prefix}_decimals"] = money.cents
      hash["#{field_prefix}_currency"] = money.currency.iso_code
    })
  }
end
