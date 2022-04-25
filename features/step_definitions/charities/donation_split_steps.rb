When("a donator splits their donation unevenly among the charities") do
  @amount = Money.new(30_00, "GBP")

  @charity_1 = FactoryBot.create(:charity)
  @charity_2 = FactoryBot.create(:charity)
  @charity_3 = FactoryBot.create(:charity)

  stub_stripe_session_creation(amount: @amount)
  make_donation(@amount,
    navigate: true,
    split: {
      @charity_1 => (@split_1 = Money.new(20_00, "GBP")),
      @charity_2 => (@split_2 = Money.new(6_00, "GBP")),
      @charity_3 => (@split_3 = Money.new(4_00, "GBP")),
    },
  )
end

Then("the donation split should appear on their donations list") do
  expect(page).to have_text(@amount.format)

  expect(page).to have_text("#{@charity_1.name}: #{@split_1.format}")
  expect(page).to have_text("#{@charity_2.name}: #{@split_2.format}")
  expect(page).to have_text("#{@charity_3.name}: #{@split_3.format}")
end

When("a donator splits their donation in a way that doesn't add up to their total donation") do
  @charity_1 = FactoryBot.create(:charity)
  @charity_2 = FactoryBot.create(:charity)
  @charity_3 = FactoryBot.create(:charity)

  amount = Money.new(30_00, "GBP")
  stub_stripe_session_creation(amount:)
  make_donation(amount,
    navigate: true,
    submit: false,
    split: {
      @charity_1 => Money.new(20_00, "GBP"),
      @charity_2 => Money.new(0),
      @charity_3 => Money.new(0),
    },
  )
end

Then("the donator should be asked to correct their split") do
  expect(page).to have_text("Your donation split doesn't add up to your total donation amount.")
end

Given("a variety of split and unsplit donations") do
  @popular_charity = FactoryBot.create(:charity, name: "Popular charity")
  @unpopular_charity = FactoryBot.create(:charity, name: "Unpopular charity")

  # £15/£15
  FactoryBot.create(:donation, amount: Money.new(30_00, "GBP"))

  # £25/£5
  FactoryBot.create(:donation,
    amount: Money.new(30_00, "GBP"),
    charity_split: {
      @popular_charity => Money.new(25_00, "GBP"),
      @unpopular_charity => Money.new(5_00, "GBP"),
    },
  )

  # £10/£5/(£7.50/£7.50)
  FactoryBot.create(:donation,
    amount: Money.new(30_00, "GBP"),
    charity_split: {
      @popular_charity => Money.new(10_00, "GBP"),
      @unpopular_charity => Money.new(5_00, "GBP"),
    },
  )
end

Then("the admin should be able to see a breakdown of amounts owed to each charity") do
  go_to_admin_area("Donation accounting")

  # 15 + 25 + 10 + 7.50 = 57.50
  expect(page).to have_text("Popular charity #{Money.new(57_50, 'GBP').format}")

  # 15 + 5 + 5 + 7.50 = 32.50
  expect(page).to have_text("Unpopular charity #{Money.new(32_50, 'GBP').format}")
end

When("the admin goes to the admin section") do
  go_to_admin_homepage
end

Then("they should not see the donation accounting section") do
  expect(page).not_to have_text("Donation accounting")
end
