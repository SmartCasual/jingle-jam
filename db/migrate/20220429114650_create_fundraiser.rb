class CreateFundraiser < ActiveRecord::Migration[7.0]
  def change
    create_table :fundraisers do |t|
      t.string :name, null: false
      t.text :description
      t.string :short_url
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :overpayment_mode, null: false, default: "pro_bono"
      t.string :state, null: false, default: "inactive"

      t.timestamps
    end

    create_table :charity_fundraisers do |t|
      t.references :charity
      t.references :fundraiser
      t.timestamps
    end

    add_reference :bundle_definitions, :fundraiser, index: true
    add_reference :donations, :fundraiser, index: true
    add_reference :keys, :fundraiser, index: true
  end
end
