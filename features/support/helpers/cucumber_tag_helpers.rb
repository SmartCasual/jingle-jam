module CucumberTagHelpers
  def self.permission_level(tags)
    # Cucumber ordered the tags by their position on the page, so the last
    # relevant permission level tag should be the most granular one.
    (tags & user_permission_levels).last
  end

  def self.user_permission_levels
    %i[
      admin
      donator
    ].freeze
  end
end

Before("not @anonymous") do |scenario|
  # e.g `"@admin"` becomes `:admin`
  tags = scenario.tags.map { |t| t.name[1..].to_sym }

  permission_level = CucumberTagHelpers.permission_level(tags)

  ensure_logged_in(as: permission_level)
end
