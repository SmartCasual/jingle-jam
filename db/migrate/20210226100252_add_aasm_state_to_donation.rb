class AddAasmStateToDonation < ActiveRecord::Migration[6.1]
  def change
    add_column :donations, :aasm_state, :string, null: false, default: "pending"
  end
end
