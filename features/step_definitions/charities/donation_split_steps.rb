When("a donator splits their donation unevenly among the charities") do
  @amount = Money.new(30_00, "GBP")

  @charity_1 = FactoryBot.create(:charity)
  @charity_2 = FactoryBot.create(:charity)
  @charity_3 = FactoryBot.create(:charity)

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

Given("a variety of split and unsplit donations") do
  @popular_charity = FactoryBot.create(:charity, name: "Popular charity")
  @unpopular_charity = FactoryBot.create(:charity, name: "Unpopular charity")

  FactoryBot.create(:donation, amount: Money.new(30_00, "GBP")) # £15 to each
  FactoryBot.create(:donation,
    amount: Money.new(30_00, "GBP"),
    charity_split: {
      @popular_charity => Money.new(25_00, "GBP"),
      @unpopular_charity => Money.new(5_00, "GBP"),
    },
  )
end

Then("the admin should be able to see a breakdown of amounts owed to each charity") do
  go_to_admin_area("Donation accounting")

  expect(page).to have_text("Popular charity #{Money.new(40_00, 'GBP').format}")
  expect(page).to have_text("Unpopular charity #{Money.new(20_00, 'GBP').format}")
end

When("the admin goes to the admin section") do
  go_to_admin_homepage
end

Then("they should not see the donation accounting section") do
  expect(page).not_to have_text("Donation accounting")
end
