class DonationAmountValidator < ActiveModel::EachValidator
  MINIMUM_DONATION = Money.new(2_00, "GBP")

  def validate_each(record, attr_name, value)
    unless Currency.supported?(record.public_send("#{attr_name}_currency"))
      record.errors.add(attr_name, "currency is not supported")
    end

    if value < MINIMUM_DONATION
      record.errors.add(attr_name, "must be at least #{MINIMUM_DONATION.format}")
    end
  end
end
