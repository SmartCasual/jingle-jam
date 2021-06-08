Given("a curated streamer") do
  @current_curated_streamer = FactoryBot.create(:curated_streamer)
end

When("a donator goes to the curated streamer's page") do
  go_to_curated_streamer(@current_curated_streamer)
end

When("they make a donation") do
  @donation_amount = Money.new(500, "GBP")
  @donation_message = "Go team!"
  make_donation(@donation_amount, message: @donation_message)
end

Then("the curated streamer page should show that donation") do
  go_to_curated_streamer(@current_curated_streamer)

  expect(page).to have_text("You")
  expect(page).to have_text("#{@donation_amount.format} Paid #{@donation_message}")
end

Then("the curated streamer's twitch should be embedded on the page") do
  expect(page).to have_twitch_embed(@current_curated_streamer.twitch_username)
end
