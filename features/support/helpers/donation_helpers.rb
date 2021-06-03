module DonationHelpers
  def make_donation(amount, message: nil, navigate: false)
    if navigate
      go_to_homepage
      click_on "Donate here!"
    end

    select amount.currency.iso_code, from: "Currency"
    fill_in "Amount", with: amount.to_s
    fill_in "Message", with: message if message

    click_on "Donate"
  end
end

World(DonationHelpers)
