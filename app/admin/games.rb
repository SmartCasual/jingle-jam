ActiveAdmin.register Game do
  permit_params(
    :name,
    keys_attributes: %i[
      _destroy
      code
      id
    ],
  )

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

    f.actions
  end

  show do
    attributes_table do
      row :name
    end

    panel "Keys" do
      table_for game.keys do
        column :code
        column :assigned, &:assigned?
      end
    end

    active_admin_comments
  end
end
