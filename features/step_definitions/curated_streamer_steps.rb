Given("a curated streamer") do
  @current_curated_streamer = FactoryBot.create(:curated_streamer)
end

Given("several curated streamers") do
  @current_curated_streamers = FactoryBot.create_list(:curated_streamer, 3)
end

When("a donator goes to the curated streamer's page") do
  @fundraiser = create(:fundraiser, :active)
  go_to_curated_streamer(@current_curated_streamer, fundraiser: @fundraiser)
end

When("they make a donation") do
  click_on "Donate here!"
  @donation_amount = Money.new(5_00, "GBP")
  @donation_message = "Go team!"
  make_donation(@donation_amount, fundraiser: @fundraiser, message: @donation_message)
end

Then("the curated streamer page should show that donation") do
  go_to_curated_streamer(@current_curated_streamer, fundraiser: @fundraiser)

  expect(page).to have_text("You")
  expect(page).to have_text("#{@donation_amount.format} Paid #{@donation_message}")
end

Then("the curated streamer's twitch should be embedded on the page") do
  expect(page).to have_twitch_embed(@current_curated_streamer.twitch_username)
end

Given("a some donations for a curated streamer") do
  @current_curated_streamer = FactoryBot.create(:curated_streamer)
  @fundraiser = create(:fundraiser, :active)
  @streamer_donations = FactoryBot.create_list(:donation, 2, fundraiser: @fundraiser, curated_streamer: @current_curated_streamer, donator_name: "Superfan")
end

Given("some other donations") do
  @non_streamer_donations = FactoryBot.create_list(:donation, 2, fundraiser: @fundraiser, curated_streamer: nil)
end

Then("a stream admin for that streamer should see the relevant donations on the stream admin page") do
  user = FactoryBot.create(:donator, curated_streamers: [@current_curated_streamer])
  log_in_as(user)

  go_to_curated_streamer(@current_curated_streamer, fundraiser: @fundraiser, admin: true)

  expect(page).to have_text("#{@current_curated_streamer.twitch_username} admin")

  @streamer_donations.each do |donation|
    expect(page).to have_text("#{donation.amount.format} Pending #{donation.message} #{donation.donator_name}")
  end

  @non_streamer_donations.each do |donation|
    expect(page).not_to have_text("#{donation.amount.format} Pending #{donation.message} #{donation.donator_name}")
  end

  expect(page).to have_text(@streamer_donations.each_with_object(Money.new(0)) { |d, sum| sum + d.amount }.format)
end

Then("a stream admin for a different streamer should not be able to see the stream admin page") do
  log_out

  streamer = FactoryBot.create(:curated_streamer)
  user = FactoryBot.create(:donator, curated_streamers: [streamer])

  log_in_as(user)
  go_to_curated_streamer(@current_curated_streamer, fundraiser: @fundraiser, admin: true)

  expect(page).not_to have_text("#{@current_curated_streamer.twitch_username} admin")
end

Then("a regular user should not be able to see the stream admin page") do
  log_out
  log_in_as(:donator)

  go_to_curated_streamer(@current_curated_streamer, fundraiser: @fundraiser, admin: true)

  expect(page).not_to have_text("#{@current_curated_streamer.twitch_username} admin")
end

Then("links to the curated streamers should be listed on the homepage") do
  create_list(:fundraiser, 3, :active, :with_live_bundle)

  go_to_homepage

  Fundraiser.active.each do |fundraiser|
    @current_curated_streamers.each do |curated_streamer|
      expect(page).to have_link(curated_streamer.twitch_username, href: fundraiser_curated_streamer_path(fundraiser, curated_streamer))
    end
  end
end

When("a donator goes to the curated streamer's shorter URL") do
  visit curated_streamer_path(@current_curated_streamer)
end

Then("the donator should be redirected to the curated streamer's page for the active fundraiser") do
  expect(current_path).to eq(fundraiser_curated_streamer_path(@first_active_fundraiser, @current_curated_streamer))
end

Then("the donator should be informed that there are no active fundraisers") do
  expect(page).to have_text("Unfortunately there are no fundraisers active at the moment")
end

Then("the donator should be offered links to the curated streamer's page for both active fundraisers") do
  expect(page).to have_text("Which fundraiser would you like to donate to?")
  expect(page).to have_link(@first_active_fundraiser.name, href: fundraiser_curated_streamer_path(@first_active_fundraiser, @current_curated_streamer))
  expect(page).to have_link(@second_active_fundraiser.name, href: fundraiser_curated_streamer_path(@second_active_fundraiser, @current_curated_streamer))
end
