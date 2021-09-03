module AASMFactories
  def self.init(factory, klass)
    klass.aasm.states.each do |state|
      factory.trait(state.name) do
        aasm_state { state.name }
      end
    end
  end
end
