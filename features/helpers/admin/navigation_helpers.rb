module Admin::NavigationHelpers
  def go_to_admin_area(area)
    within ".admin_namespace .header" do
      click_on area
    end
  end

  def go_to_admin_game(game, edit: false)
    go_to_admin_area "Games"

    within "#game_#{game.id}" do
      click_on(edit ? "Edit" : "View")
    end
  end
end

World(Admin::NavigationHelpers)
