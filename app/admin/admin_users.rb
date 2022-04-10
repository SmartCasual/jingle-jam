ActiveAdmin.register AdminUser do
  permit_params(
    *%i[
      data_entry
      email
      full_access
      manages_users
      name
      password
      password_confirmation
      support
    ],
  )

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :permissions do |user|
      user.permissions.to_sentence.capitalize
    end
    actions
  end

  filter :name
  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :password, required: false
      f.input :password_confirmation
    end

    f.inputs "Permissions" do
      f.input :support
      f.input :data_entry
      f.input :manages_users
      f.input :full_access
    end

    f.actions
  end

  controller do
    def update
      model = :admin_user

      if params[model][:password].blank?
        %w[password password_confirmation].each { |p| params[model].delete(p) }
      end

      super
    end
  end
end
