module NavigationHelpers
  def go_to_homepage
    visit "/"
  end
end

World(NavigationHelpers)
