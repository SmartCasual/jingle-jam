ActiveAdmin.register Game do
  permit_params(
    :bulk_key_entry,
    :name,
    keys_attributes: %i[
      _destroy
      code
      id
    ],
  )

  index do
    selectable_column
    id_column
    column :name
    column :description
    column :unassigned_keys do |game|
      game.keys.unassigned.count
    end
    column :assigned_keys do |game|
      game.keys.assigned.count
    end
    column :created_at
    column :updated_at

    actions do |game|
      link_to "Upload keys via CSV", csv_upload_admin_game_path(game)
    end
  end

  form do |f|
    f.semantic_errors

    f.inputs do
      f.input :name
    end

    f.inputs do
      f.has_many(:keys, heading: "Keys", allow_destroy: true) do |key|
        key.input :code
      end
    end

    f.inputs do
      f.input :bulk_key_entry, as: :text
    end

    f.actions
  end

  show do
    attributes_table do
      row :name
      row :description
      row :unassigned_keys do |game|
        game.keys.unassigned.count
      end
      row :assigned_keys do |game|
        game.keys.assigned.count
      end
    end

    active_admin_comments
  end

  member_action :csv_upload, method: :get, title: "CSV upload"
  member_action :upload_csv, method: :post do
    params.fetch(:csv).tempfile.each_line do |code|
      resource.keys.create(code: code.chomp)
    end
  end
end
