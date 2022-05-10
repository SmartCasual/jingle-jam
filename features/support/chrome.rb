Capybara.register_driver(:selenium_chrome_devtools) do |app|
  if (driver = Capybara.drivers[:selenium_chrome].call).nil?
    raise "Cannot find selenium_chrome driver"
  end

  browser_options = driver.options.fetch(:capabilities)
  if (ENV.fetch("HEADLESS", nil) || ENV.fetch("HL", nil)) == "false"
    browser_options.args << "--auto-open-devtools-for-tabs" if ENV.fetch("DEVTOOLS", nil) && ENV.fetch("DEVTOOLS", nil) != "false"
  else
    browser_options.args << "--window-size=1920,1080"
    browser_options.args << "--headless"
  end

  Capybara::Selenium::Driver.new(app, browser: :chrome, capabilities: browser_options)
end

Capybara.default_driver = :selenium_chrome_devtools
