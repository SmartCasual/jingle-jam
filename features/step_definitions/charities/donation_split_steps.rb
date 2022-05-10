When("a donator splits their donation unevenly among the charities") do
  @amount = Money.new(30_00, "GBP")

  @fundraiser = create(:fundraiser, :active,
    name: "Fundraiser",
    bundles: build_list(:bundle, 1, :live),
  )

  @charity_1 = create(:charity, fundraisers: [@fundraiser])
  @charity_2 = create(:charity, fundraisers: [@fundraiser])
  @charity_3 = create(:charity, fundraisers: [@fundraiser])

  make_donation(@amount,
    navigate: true,
    fundraiser: @fundraiser,
    split: {
      @charity_1 => (@split_1 = Money.new(20_00, "GBP")),
      @charity_2 => (@split_2 = Money.new(6_00, "GBP")),
      @charity_3 => (@split_3 = Money.new(4_00, "GBP")),
    },
  )
end

Then("the donation split should appear on their donations list") do
  go_to_donations(fundraiser: @fundraiser)
  expect(page).to have_text(@amount.format)

  expect(page).to have_text("#{@charity_1.name}: #{@split_1.format}")
  expect(page).to have_text("#{@charity_2.name}: #{@split_2.format}")
  expect(page).to have_text("#{@charity_3.name}: #{@split_3.format}")
end

When("a donator splits their donation in a way that doesn't add up to their total donation") do
  @fundraiser = create(:fundraiser, :active,
    name: "Fundraiser",
    bundles: build_list(:bundle, 1, :live),
  )

  @charity_1 = create(:charity, fundraisers: [@fundraiser])
  @charity_2 = create(:charity, fundraisers: [@fundraiser])
  @charity_3 = create(:charity, fundraisers: [@fundraiser])

  make_donation(Money.new(30_00, "GBP"),
    navigate: true,
    submit: false,
    fundraiser: @fundraiser,
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
  @fundraiser = create(:fundraiser, :active,
    name: "Fundraiser",
    bundles: build_list(:bundle, 1, :live),
  )

  @popular_charity = create(:charity, name: "Popular charity", fundraisers: [@fundraiser])
  @unpopular_charity = create(:charity, name: "Unpopular charity", fundraisers: [@fundraiser])

  # £15/£15
  create(:donation, amount: Money.new(30_00, "GBP"))

  # £25/£5
  create(:donation,
    amount: Money.new(30_00, "GBP"),
    charity_split: {
      @popular_charity => Money.new(25_00, "GBP"),
      @unpopular_charity => Money.new(5_00, "GBP"),
    },
  )

  # £10/£5/(£7.50/£7.50)
  create(:donation,
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
