Capybara.register_driver(:selenium_chrome_devtools) do |app|
  driver = Capybara.drivers[:selenium_chrome].call

  browser_options = driver.options[:options]
  if (ENV.fetch("HEADLESS", nil) || ENV.fetch("HL", nil)) == "false"
    browser_options.args << "--auto-open-devtools-for-tabs" if ENV.fetch("DEVTOOLS", nil) && ENV.fetch("DEVTOOLS", nil) != "false"
  else
    browser_options.args << "--window-size=1920,1080"
    browser_options.headless!
  end

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

Capybara.default_driver = :selenium_chrome_devtools
