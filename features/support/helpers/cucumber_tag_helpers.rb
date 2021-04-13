module CucumberTagHelpers
  def self.permission_level(tags)
    # Cucumber ordered the tags by their position on the page, so the last
    # relevant permission level tag should be the most granular one.
    (tags & user_permission_levels).last || :anonymous
  end

  def self.user_permission_levels
    %i[
      admin
      donator
      anonymous
    ].freeze
  end

  def self.access_flags(tags)
    tags & admin_access_flags
  end

  def self.admin_access_flags
    %i[
      data_entry
      full_access
      manages_users
      support
    ].freeze
  end
end

Before do |scenario|
  # e.g `"@admin"` becomes `:admin`
  tags = scenario.tags.map { |t| t.name[1..].to_sym }

  permission_level = CucumberTagHelpers.permission_level(tags)

  case permission_level
  when :admin
    admin = ensure_logged_in(as: permission_level)
    admin.update(
      CucumberTagHelpers.access_flags(tags).index_with(true),
    )
  when :donator
    ensure_logged_in(as: permission_level)
  end
end
