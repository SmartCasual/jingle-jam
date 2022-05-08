module Admin::NavigationHelpers
  def reload_page
    visit current_path
  end

  def go_to_admin_homepage
    visit "/admin"
  end

  def go_to_admin_area(area)
    within ".admin_namespace .header" do
      click_on area
    end
  end

  def go_to_admin_games
    go_to_admin_area "Games"
  end

  def go_to_admin_game(game, edit: false)
    go_to_admin_record(game, within: "Games", edit:)
  end

  def go_to_game_csv_upload(game)
    go_to_admin_games

    click_on "Upload keys via CSV"
    expect(page).to have_text("#{game.name} CSV upload")
  end

  def go_to_admin_bundle(bundle, edit: false)
    go_to_admin_record(bundle, within: "Bundles", edit:)
  end

  def go_to_admin_users
    go_to_admin_area "Admin Users"
  end

  def go_to_admin_user(admin_user, edit: false)
    go_to_admin_record(admin_user, within: "Admin Users", edit:)
  end

  def go_to_admin_record(record, within:, edit:)
    go_to_admin_area(within)

    within "##{record.class.name.underscore}_#{record.id}" do
      click_on(edit ? "Edit" : "View")
    end
  end
end

World(Admin::NavigationHelpers)
