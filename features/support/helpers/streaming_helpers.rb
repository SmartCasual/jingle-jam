module StreamingHelpers
  def have_twitch_embed(twitch_username) # rubocop:disable Naming/PredicateName
    have_css("#twitch-embed[data-channel='#{twitch_username}'] iframe[src*='.twitch.tv']")
  end
end

World(StreamingHelpers)
