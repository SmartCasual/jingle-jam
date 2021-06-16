module NavigationHelpers
  def go_to_homepage
    go_to_if_not_at("/")
  end

  def go_to_game_keys
    go_to_if_not_at(keys_path)
  end

  def go_to_profile(donator)
    click_on donator.display_name
  end

  def go_to_curated_streamer(streamer, admin: false)
    path = if admin
      curated_streamer_admin_path(streamer)
    else
      curated_streamer_path(streamer)
    end

    go_to_if_not_at(path)
  end

  def go_to_if_not_at(path)
    visit path unless current_path == path
  end
end

World(NavigationHelpers)
