ActiveAdmin.register_page "Donation accounting" do
  content do
    all_charities = Charity.all

    breakdown = Donation
      .includes(charity_splits: :charity)
      .find_each.with_object(Hash.new { |h, k| h[k] = Money.new(0) }) do |donation, hash|
        if donation.charity_splits.any?
          donation.charity_splits.each do |split|
            hash[split.charity] += split.amount
          end
        else
          all_charities.each do |charity|
            hash[charity] += donation.amount / all_charities.count
          end
        end
      end

    table do
      caption "Donation breakdown"

      thead do
        tr do
          th "Charity"
          th "Total donations"
        end
      end

      tbody do
        breakdown.sort_by { |c, _| c.name }.each do |charity, total_donations|
          tr do
            td charity.name
            td total_donations.format
          end
        end
      end
    end
  end
end
