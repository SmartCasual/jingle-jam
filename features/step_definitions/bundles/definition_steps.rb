Then("a donator should see a/the bundle priced at {amount}") do |amount|
  go_to_first_fundraiser
  expect(page).to have_css(".bundle-definition h3", text: amount.format)
end

Then("a donator should see {int} bundle(s)") do |bundle_definition_count|
  go_to_first_fundraiser
  expect(page).to have_css(".bundle-definition", count: bundle_definition_count)
end

Then("a donator should see the bundle priced at {amount} with the following tiers:") do |amount, table|
  expect(page).to have_css(".bundle-definition h3", text: amount.format)

  table.symbolic_hashes.map do |hash|
    if hash[:tier_price] == "bundle price"
      expect(page).to have_css(".bundle-definition li", text: hash[:game], exact_text: true)
    else
      expect(page).to have_css(".bundle-definition li",
        text: "#{hash[:game]}: #{Monetize.parse(hash[:tier_price]).format}",
        exact_text: true,
      )
    end
  end
end
