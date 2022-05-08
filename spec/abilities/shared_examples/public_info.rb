RSpec.shared_examples "allows reading public information" do
  it "allows reading live bundles" do
    expect(ability).not_to be_able_to(:read, bundle)
    bundle.publish!
    expect(ability).to be_able_to(:read, bundle)
  end

  it "allows reading tiers" do
    expect(ability).to be_able_to(:read, bundle_tier)
  end

  it "allows reading charities" do
    expect(ability).to be_able_to(:read, charity)
  end

  it "allows reading games" do
    expect(ability).to be_able_to(:read, game)
  end

  it "allows reading game entries" do
    expect(ability).to be_able_to(:read, bundle_tier_game)
  end
end

RSpec.shared_examples "allows managing public information" do
  it "allows managing bundles" do
    expect(ability).to be_able_to(:manage, bundle)
  end

  it "allows managing tiers" do
    expect(ability).to be_able_to(:manage, bundle_tier)
  end

  it "allows managing charities" do
    expect(ability).to be_able_to(:manage, charity)
  end

  it "allows managing games" do
    expect(ability).to be_able_to(:manage, game)
  end

  it "allows managing game entries" do
    expect(ability).to be_able_to(:manage, bundle_tier_game)
  end
end

RSpec.shared_examples "disallows reading public information" do
  it "disallows reading bundles" do
    expect(ability).not_to be_able_to(:read, bundle)
  end

  it "disallows reading tiers" do
    expect(ability).not_to be_able_to(:manage, bundle_tier)
  end

  it "disallows reading charities" do
    expect(ability).not_to be_able_to(:read, charity)
  end

  it "disallows reading games" do
    expect(ability).not_to be_able_to(:read, game)
  end

  it "disallows reading game entries" do
    expect(ability).not_to be_able_to(:read, bundle_tier_game)
  end
end

RSpec.shared_examples "disallows modifying public information" do
  it "disallows modifying bundles" do
    expect(ability).not_to be_able_to(%I[manage update delete], bundle)
  end

  it "disallows modifying tiers" do
    expect(ability).not_to be_able_to(:manage, bundle_tier)
  end

  it "disallows modifying charities" do
    expect(ability).not_to be_able_to(%I[manage update delete], charity)
  end

  it "disallows modifying games" do
    expect(ability).not_to be_able_to(%I[manage update delete], game)
  end

  it "disallows modifying game entries" do
    expect(ability).not_to be_able_to(%I[manage update delete], bundle_tier_game)
  end
end
