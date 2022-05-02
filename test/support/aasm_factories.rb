module AASMFactories
  def self.init(factory, klass)
    klass.aasm.states.each do |state|
      factory.trait(state.name) do
        add_attribute(klass.aasm.attribute_name) { state.name }
      end
    end
  end
end
