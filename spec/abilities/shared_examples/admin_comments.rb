RSpec.shared_examples "disallows accessing admin comments" do
  it "disallows accessing admin comments" do
    expect(ability).not_to be_able_to(%I[create read update delete manage], comment)
  end
end

RSpec.shared_examples "allows adding comments on public information" do |public_class:|
  context "with a general comment" do
    let(:comment) { ActiveAdmin::Comment.new(resource_type: public_class.name) }

    it "allows adding comments on public information" do
      expect(ability).to be_able_to(%I[create read], comment)
      expect(ability).not_to be_able_to(%I[update delete manage], comment)
    end
  end
end

RSpec.shared_examples "allows managing own comments on public information" do |public_class:|
  let(:comment) { ActiveAdmin::Comment.new(resource_type: public_class.name, author: user) }

  it "allows managing own comments on public information" do
    expect(ability).to be_able_to(:manage, comment)
  end
end
