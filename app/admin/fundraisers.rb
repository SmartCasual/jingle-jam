ActiveAdmin.register Fundraiser do
  permit_params(
    :description,
    :ends_at,
    :main_currency,
    :name,
    :overpayment_mode,
    :short_url,
    :starts_at,
    :state,
    bundles_attributes: %i[
      _destroy
      fundraiser_id
      id
      name
    ],
  )

  index do
    selectable_column
    id_column
    column :name
    column :description
    column :main_currency
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
      f.input :main_currency,
        as: :select,
        collection: Currency.present_all,
        include_blank: false,
        required: true
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
      row :main_currency
      row :starts_at
      row :ends_at
      row :overpayment_mode
      row :short_url
      row :state
    end

    panel "Bundles" do
      table_for fundraiser.bundles do
        column :name
      end
    end
  end
end
