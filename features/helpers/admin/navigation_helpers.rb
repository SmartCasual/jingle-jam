module Admin::NavigationHelpers
  def go_to_admin_area(area)
    within ".admin_namespace .header" do
      click_on area
    end
  end

  def go_to_admin_game(game, edit: false)
    go_to_admin_record(game, within: "Games", edit: edit)
  end

  def go_to_admin_bundle_definition(bundle_definition, edit: false)
    go_to_admin_record(bundle_definition, within: "Bundle Definitions", edit: edit)
  end

  def go_to_admin_users
    go_to_admin_area "Admin Users"
  end

  def go_to_admin_user(admin_user, edit: false)
    go_to_admin_record(admin_user, within: "Admin Users", edit: edit)
  end

  def go_to_admin_record(record, within:, edit:)
    go_to_admin_area(within)

    within "##{record.class.name.underscore}_#{record.id}" do
      click_on(edit ? "Edit" : "View")
    end
  end
end

World(Admin::NavigationHelpers)
