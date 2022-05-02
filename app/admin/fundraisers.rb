ActiveAdmin.register Fundraiser do
  permit_params :name, :description, :starts_at, :ends_at, :overpayment_mode, :short_url, :state,
bundle_definitions_attributes: %i[id fundraiser_id human_price name price_currency _destroy]

  index do
    selectable_column
    id_column
    column :name
    column :description
    column :starts_at
    column :ends_at
    column :overpayment_mode
    column :short_url
    column :state

    actions do |fundraiser|
      ActiveAdmin::AasmHelper.buttons(fundraiser, self)
    end
  end

  ActiveAdmin::AasmHelper.member_actions(Fundraiser, self)

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :description
      f.input :starts_at
      f.input :ends_at
      f.input :overpayment_mode, as: :select, collection: Fundraiser::OVERPAYMENT_MODES
      f.input :short_url
      f.input :state, as: :select, collection: Fundraiser.aasm.states.map(&:name)
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :description
      row :starts_at
      row :ends_at
      row :overpayment_mode
      row :short_url
      row :state
    end

    panel "Bundle definitions" do
      table_for fundraiser.bundle_definitions do
        column :name
        column :human_price
        column :price_currency
      end
    end
  end
end
