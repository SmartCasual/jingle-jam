ActiveAdmin.register BundleDefinition do
  permit_params(
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
    column("State", :aasm_state) { |bd| bd.aasm_state.humanize }

    actions do |bundle_definition|
      if bundle_definition.draft?
        item "Publish", publish_admin_bundle_definition_path(bundle_definition), method: :post,
                                                                                 data: { confirm: "Make bundle live?" }
      end
      if bundle_definition.live?
        item "Retract", retract_admin_bundle_definition_path(bundle_definition), method: :post,
                                                                                 data: { confirm: "Retract bundle?" }
      end
    end
  end

  member_action :publish, method: :post do
    resource.publish!
    redirect_to admin_bundle_definitions_path, notice: "Bundle definition published"
  end

  member_action :retract, method: :post do
    resource.retract!
    redirect_to admin_bundle_definitions_path, notice: "Bundle definition retracted"
  end

  controller do
    before_action :prevent_edit, only: [:edit]

  private

    def prevent_edit
      redirect_to admin_bundle_definitions_path, alert: "Bundle definitions cannot be edited" if resource.live?
    end
  end
end
