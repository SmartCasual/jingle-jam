url = "http://#{ENV['SELENIUM_HOST']}:#{ENV['SELENIUM_PORT']}/wd/hub"
capabilities = Selenium::WebDriver::Remote::Capabilities.chrome
Capybara.register_driver(:selenium_chrome_devtools) do |app|
  driver = Capybara.drivers[:selenium_chrome].call

  browser_options = driver.options[:options]
  if (ENV["HEADLESS"] || ENV["HL"]) == "false"
    browser_options.args << "--auto-open-devtools-for-tabs" if ENV["DEVTOOLS"] && ENV["DEVTOOLS"] != "false"
  else
    browser_options.args << "--window-size=1920,1080"
    browser_options.headless!
  end

  Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    url: url,
    desired_capabilities: capabilities,
  )
  # Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

Capybara.default_driver = :selenium_chrome_devtools
