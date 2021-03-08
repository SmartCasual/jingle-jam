module NavigationHelpers
  def go_to_homepage
    go_to_if_not_at("/")
  end

  def go_to_if_not_at(path)
    visit path unless current_path == path
  end
end

World(NavigationHelpers)
