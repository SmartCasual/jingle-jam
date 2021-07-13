ActiveAdmin.register_page "Donation accounting" do
  content do
    all_charities = Charity.all

    breakdown = Donation
      .includes(charity_splits: :charity)
      .find_each.with_object(Hash.new { |h, k| h[k] = Money.new(0) }) do |donation, hash|
        # TODO: This needs unit testing
        explicit_split = Money.new(0)
        donation.charity_splits.each do |split|
          hash[split.charity] += split.amount
          explicit_split += split.amount
        end

        implicit_split = donation.amount - explicit_split

        # TODO: This needs changing to split donations en masse rather than
        # per-donation, to avoid fractional losses during division.
        all_charities.each do |charity|
          hash[charity] += implicit_split / all_charities.count
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
