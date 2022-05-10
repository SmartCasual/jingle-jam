Around do |scenario, block|
  if (time_tag = scenario.tags.find { |t| t.name.start_with?("@set-time:") })
    timestamp = time_tag.name.sub("@set-time:", "")
    Timecop.freeze(timestamp, &block)
  else
    block.call
  end
end
