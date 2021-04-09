RSpec.shared_examples "disallows accessing admin users" do
  it "disallows accessing admin users" do
    expect(ability).not_to be_able_to(%I[create read update delete manage], admin_user)
  end
end

RSpec.shared_examples "allows managing admin users" do
  it "allows managing admin users" do
    expect(ability).to be_able_to(%I[manage], admin_user)
  end
end
