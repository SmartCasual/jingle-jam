# rubocop:disable Rails/Output
if Rails.env.development? || ENV.fetch("FORCE_SEEDS", nil) == "true"
  puts "Creating admin user admin@example.com"
  AdminUser.create!(
    name: "admin",
    email: "admin@example.com",
    password: "password123",
    password_confirmation: "password123",
    full_access: true,
  )

  puts "Creating an active fundraiser"
  fundraiser = Fundraiser.create!(name: "Manatee Matinée")
  fundraiser.activate!

  BundleDefinition.without_assignments do
    puts "Creating bundle definition"
    bundef = BundleDefinition.create!(
      price_decimals: 25_00,
      name: "Test bundle",
      fundraiser:,
    )

    bundef.bundle_definition_game_entries.create!(
      game: Game.new(name: "The Witness"),
    )

    bundef.bundle_definition_game_entries.create!(
      game: Game.new(name: "Doom"),
      price_decimals: 10_00,
    )

    Game.all.each do |game|
      puts "Adding 1,000 keys for #{game.name}"
      1_000.times do
        game.keys.create(
          code: SecureRandom.uuid,
          fundraiser:,
        )
      end
    end
  end

  puts "Creating charities"
  Charity.create(name: "Help the Penguins", fundraisers: [fundraiser])
  Charity.create(name: "Justice for Dugongs", fundraisers: [fundraiser])
  Charity.create(name: "Free All Bats", fundraisers: [fundraiser])
end
# rubocop:enable Rails/Output
