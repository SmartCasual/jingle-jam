RSpec.shared_examples "disallows accessing private information" do
  it "disallows accessing bundles" do
    expect(ability).not_to be_able_to(%I[read manage update delete], bundle)
  end

  it "disallows accessing donations" do
    expect(ability).not_to be_able_to(%I[read manage update delete], donation)
  end

  it "disallows accessing donators" do
    expect(ability).not_to be_able_to(%I[read manage update delete], donator)
  end

  it "disallows accessing keys" do
    expect(ability).not_to be_able_to(%I[read manage update delete], key)
  end
end

RSpec.shared_examples "allows reading donation information" do
  it "allows reading bundles" do
    expect(ability).to be_able_to(:read, bundle)
  end

  it "allows reading charities" do
    expect(ability).to be_able_to(:read, donation)
  end
end
