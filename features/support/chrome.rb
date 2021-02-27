Capybara.register_driver(:selenium_chrome_devtools) do |app|
  driver = Capybara.drivers[:selenium_chrome].call

  browser_options = driver.options[:options]
  if (ENV["HEADLESS"] || ENV["HL"]) == "false"
    browser_options.args << "--auto-open-devtools-for-tabs"
  else
    browser_options.headless!
  end

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

Capybara.default_driver = :selenium_chrome_devtools
