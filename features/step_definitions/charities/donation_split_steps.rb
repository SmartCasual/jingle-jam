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
