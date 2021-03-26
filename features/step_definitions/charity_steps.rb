Given("the following charities:") do |table|
  table.symbolic_hashes.each do |hash|
    FactoryBot.create(:charity, name: hash[:charity], description: hash[:description])
  end
end
