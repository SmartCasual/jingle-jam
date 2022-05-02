module NavigationHelpers
  def go_to_homepage
    go_to_if_not_at("/")
  end

  def go_to_donations(fundraiser: nil)
    go_to_homepage
    click_on (fundraiser || Fundraiser.active.first).name
    click_on "See current donations"
  end

  def go_to_game_keys
    go_to_if_not_at(account_keys_path)
  end

  def go_to_profile(donator)
    click_on donator.display_name
  end

  def go_to_curated_streamer(streamer, fundraiser: nil, admin: false)
    fundraiser ||= Fundraiser.active.first

    path = if admin
      admin_fundraiser_curated_streamer_path(fundraiser, streamer)
    else
      fundraiser_curated_streamer_path(fundraiser, streamer)
    end

    go_to_if_not_at(path)
  end

  def go_to_first_fundraiser
    go_to_fundraiser(name: Fundraiser.active.first.name)
  end

  def go_to_fundraiser(name:)
    go_to_homepage
    click_on name
  end

  def go_to_if_not_at(path)
    if current_path == path
      false
    else
      visit path
      true
    end
  end
end

World(NavigationHelpers)
