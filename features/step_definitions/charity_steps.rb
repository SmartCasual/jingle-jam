Given("the following charities:") do |table|
  table.symbolic_hashes.each do |hash|
    create(:charity,
      name: hash[:charity],
      description: hash[:description],
      fundraisers: [create(:fundraiser, :active, name: hash[:fundraiser])],
    )
  end
end
