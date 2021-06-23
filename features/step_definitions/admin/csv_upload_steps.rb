When("an admin uploads a CSV with game keys for a game") do
  @game = FactoryBot.create(:game)
  go_to_game_csv_upload(@game)

  @keys = (1..5).map { SecureRandom.uuid }

  file = Tempfile.open("keys.csv")

  begin
    @keys.each { |k| file.puts k }

    file.close

    attach_file "Attach file", file.path

    click_on "Upload"
  ensure
    file.close
    file.unlink
  end
end

Then("the game keys should be added to that game") do
  go_to_admin_game(@game)

  expect(page).to have_css(".col-code", count: @keys.count + 1)
  @keys.each { |k| expect(page).to have_text(k) }
end
