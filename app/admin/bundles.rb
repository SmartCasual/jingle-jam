ActiveAdmin.register Bundle do
  permit_params(
    :fundraiser_id,
    :name,
    bundle_tiers_attributes: [
      :_destroy,
      :ends_at,
      :human_price,
      :id,
      :name,
      :price_currency,
      :starts_at,
      { bundle_tier_games_attributes: %i[
        _destroy
        id
        game_id
      ] },
    ],
  )

  form do |f|
    f.semantic_errors

    f.inputs do
      f.input :name, required: true
      f.input :fundraiser, required: true, as: :select, collection: Fundraiser.all.map { |fr| [fr.name, fr.id] }
    end

    f.inputs do
      f.has_many(:bundle_tiers,
        for: [:bundle_tiers, f.object.bundle_tiers.order(price_decimals: :desc)],
        heading: "Bundle tiers",
        allow_destroy: -> (t) { t.bundle.bundle_tiers.count > 1 },
        new_record: "Add a bundle tier",
      ) do |tier|
        tier.input :name
        tier.money :price,
          required: true,
          default_currency: bundle.fundraiser&.main_currency
        tier.input :starts_at, as: :datepicker
        tier.input :ends_at, as: :datepicker

        tier.has_many(:bundle_tier_games,
          heading: "Games",
          allow_destroy: true,
          new_record: "Add a game to this tier",
        ) do |game_entry|
          game_entry.input :game, required: true
        end
      end
    end

    f.actions
  end

  show do
    attributes_table do
      row :name
      row :price do |bundle|
        bundle.highest_tier&.human_price(symbol: true)
      end
      row :fundraiser
    end

    bundle.bundle_tiers.sort_by(&:price).reverse.each do |tier|
      attributes_table_for tier do
        row :name
        row :price do
          tier.human_price(symbol: true)
        end
        row :starts_at
        row :ends_at
        row :games do
          tier.bundle_tier_games.map(&:game).map(&:name).join(", ")
        end
      end
    end

    active_admin_comments
  end

  index do
    selectable_column

    column :name
    column :price do |bundle|
      bundle.highest_tier&.human_price(symbol: true)
    end
    column :fundraiser
    column("State", :aasm_state) { |bd| bd.aasm_state.humanize }

    actions do |bundle|
      ActiveAdmin::AasmHelper.buttons(bundle, self)
    end
  end

  ActiveAdmin::AasmHelper.member_actions(Bundle, self)

  controller do
    before_action :prevent_edit, only: [:edit]

  private

    def prevent_edit
      redirect_to admin_bundles_path, alert: "Live bundles cannot be edited" if resource.live?
    end
  end
end
