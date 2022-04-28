# rubocop:disable Rails/Output
if Rails.env.development? || ENV.fetch("FORCE_SEEDS", nil) == "true"
  puts "Creating admin user admin@example.com"
  AdminUser.create!(
    name: "admin",
    email: "admin@example.com",
    password: "password123",
    password_confirmation: "password123",
  )

  BundleDefinition.without_assignments do
    puts "Creating bundle definition"
    bundef = BundleDefinition.create!(
      price_decimals: 25_00,
      name: "Test bundle",
    )

    bundef.bundle_definition_game_entries.create!(
      game: Game.new(name: "The Witness"),
    )

    bundef.bundle_definition_game_entries.create!(
      game: Game.new(name: "Doom"),
      price_decimals: 10_00,
    )

    puts "Adding 10,000 keys per game"
    Game.all.each do |game|
      10_000.times do
        game.keys.create(code: SecureRandom.uuid)
      end
    end
  end

  puts "Creating charities"
  Charity.create(name: "Help the Penguins")
  Charity.create(name: "Justice for Dugongs")
  Charity.create(name: "Free All Bats")
end
# rubocop:enable Rails/Output
