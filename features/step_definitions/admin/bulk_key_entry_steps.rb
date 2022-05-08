When("an admin enters a list of game keys for a game") do
  @game = create(:game)
  go_to_admin_game(@game, edit: true)

  @keys = (1..5).map { SecureRandom.uuid }

  fill_in "Bulk key entry", with: @keys.join("\n")
  click_on "Update Game"
end
