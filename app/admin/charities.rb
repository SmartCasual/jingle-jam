ActiveAdmin.register Charity do
  permit_params :name, :description, :fundraisers

  index do
    selectable_column
    id_column
    column :name
    column :description
    column :fundraisers do |charity|
      charity.fundraisers.map(&:name).to_sentence
    end
    actions
  end

  filter :name
  filter :description
  filter :fundraisers

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
      f.input :fundraisers, as: :select, multiple: true, collection: Fundraiser.all.map { |fr| [fr.name, fr.id] }
    end
    f.actions
  end
end
