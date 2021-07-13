module DonationHelpers
  def make_donation(amount, split: {}, message: nil, navigate: false, submit: true)
    if navigate
      go_to_homepage
      click_on "Donate here!"
    end

    select amount.currency.iso_code, from: "Currency"
    fill_in "Amount", with: amount.to_s
    fill_in "Message", with: message if message

    if split.present?
      split.each do |charity, split_amount|
        find("li[data-charity-id='#{charity.id}'] input.manual")
          .set(split_amount.to_s, clear: :backspace)

        within "li[data-charity-id='#{charity.id}']" do
          check "Lock slider"
        end
      end
    end

    click_on "Donate" if submit
  end
end

World(DonationHelpers)
