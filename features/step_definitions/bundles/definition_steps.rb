Then("a donator should see a/the bundle priced at {amount}") do |amount|
  go_to_first_fundraiser
  expect(page).to have_css(".bundle h3")
  expect(page).to have_text("Donate #{amount.format} or more to receive everything in this bundle.")
end

Then("a donator should see {int} bundle(s)") do |bundle_count|
  go_to_first_fundraiser
  expect(page).to have_css(".bundle", count: bundle_count)
end

Then("a donator should see the bundle priced at {amount} with the following tiers:") do |amount, table|
  expect(page).to have_css(".bundle h3")
  expect(page).to have_text("Donate #{amount.format} or more to receive everything in this bundle.")

  table.symbolic_hashes.each.with_index do |hash, index|
    within ".bundle .tier:nth-child(#{index + 1})" do
      expect(page).to have_css("h4", text: hash.fetch(:tier))
      expect(page).to have_css(".game", text: hash.fetch(:game))
    end
  end
end
