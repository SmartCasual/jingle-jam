ActiveAdmin.register BundleDefinition do
  permit_params(
    :human_price,
    :name,
    :price_currency,
    bundle_definition_game_entries_attributes: [
      :game_id,
      :human_price,
      :id,
      :price_currency,
    ],
  )

  form do |f|
    f.semantic_errors

    f.inputs do
      f.input :name
      f.money :price, required: true
    end

    f.inputs do
      f.has_many(:bundle_definition_game_entries, heading: "Game entries", allow_destroy: true, new_record: "Add game entry") do |entry|
        entry.input :game
        entry.money :price
      end
    end

    f.actions
  end

  show do
    attributes_table do
      row :name
      row :price do |bundle_definition|
        bundle_definition.human_price(symbol: true)
      end
    end

    panel "Game entries" do
      table_for bundle_definition.bundle_definition_game_entries do
        column :game
        column :price do |entry|
          entry.human_price(symbol: true)
        end
      end
    end

    active_admin_comments
  end
end
