RSpec.shared_examples "allows reading public information" do
  it "allows reading bundle definitions" do
    expect(ability).to be_able_to(:read, bundle_definition)
  end

  it "allows reading charities" do
    expect(ability).to be_able_to(:read, charity)
  end

  it "allows reading games" do
    expect(ability).to be_able_to(:read, game)
  end

  it "allows reading game entries" do
    expect(ability).to be_able_to(:read, game_entry)
  end
end

RSpec.shared_examples "allows managing public information" do
  it "allows reading bundle definitions" do
    expect(ability).to be_able_to(:manage, bundle_definition)
  end

  it "allows reading charities" do
    expect(ability).to be_able_to(:manage, charity)
  end

  it "allows reading games" do
    expect(ability).to be_able_to(:manage, game)
  end

  it "allows reading game entries" do
    expect(ability).to be_able_to(:manage, game_entry)
  end
end

RSpec.shared_examples "disallows reading public information" do
  it "disallows reading bundle definitions" do
    expect(ability).not_to be_able_to(:read, bundle_definition)
  end

  it "disallows reading charities" do
    expect(ability).not_to be_able_to(:read, charity)
  end

  it "disallows reading games" do
    expect(ability).not_to be_able_to(:read, game)
  end

  it "disallows reading game entries" do
    expect(ability).not_to be_able_to(:read, game_entry)
  end
end

RSpec.shared_examples "disallows modifying public information" do
  it "disallows modifying bundle definitions" do
    expect(ability).not_to be_able_to(%I[manage update delete], bundle_definition)
  end

  it "disallows modifying charities" do
    expect(ability).not_to be_able_to(%I[manage update delete], charity)
  end

  it "disallows modifying games" do
    expect(ability).not_to be_able_to(%I[manage update delete], game)
  end

  it "disallows modifying game entries" do
    expect(ability).not_to be_able_to(%I[manage update delete], game_entry)
  end
end
