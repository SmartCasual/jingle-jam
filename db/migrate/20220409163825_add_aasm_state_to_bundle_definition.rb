class AddAasmStateToBundleDefinition < ActiveRecord::Migration[7.0]
  def change
    add_column :bundle_definitions, :aasm_state, :string, null: false, default: "draft"
  end
end
