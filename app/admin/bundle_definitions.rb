ActiveAdmin.register BundleDefinition do
  permit_params(
    :fundraiser_id,
    :human_price,
    :name,
    :price_currency,
    bundle_definition_game_entries_attributes: %i[
      _destroy
      game_id
      human_price
      id
      price_currency
    ],
  )

  form do |f|
    f.semantic_errors

    f.inputs do
      f.input :name
      f.money :price, required: true
      f.input :fundraiser, as: :select, collection: Fundraiser.all.map { |fr| [fr.name, fr.id] }
    end

    f.inputs do
      f.has_many(:bundle_definition_game_entries,
        heading: "Game entries",
        allow_destroy: true,
        new_record: "Add game entry",
      ) do |entry|
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
      row :fundraiser
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

  index do
    selectable_column

    column :name
    column :price do |bundle_definition|
      bundle_definition.human_price(symbol: true)
    end
    column :fundraiser
    column("State", :aasm_state) { |bd| bd.aasm_state.humanize }

    actions do |bundle_definition|
      ActiveAdmin::AasmHelper.buttons(bundle_definition, self)
    end
  end

  ActiveAdmin::AasmHelper.member_actions(BundleDefinition, self)

  controller do
    before_action :prevent_edit, only: [:edit]

  private

    def prevent_edit
      redirect_to admin_bundle_definitions_path, alert: "Live bundle definitions cannot be edited" if resource.live?
    end
  end
end
