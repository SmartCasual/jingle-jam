Capybara.register_driver(:selenium_chrome_devtools) do |app|
  driver = Capybara.drivers[:selenium_chrome].call

  browser_options = driver.options[:options].tap do |options|
    options.args << "--auto-open-devtools-for-tabs"
  end

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

if (ENV["HEADLESS"] || ENV["HL"]) == "false"
  Capybara.default_driver = Capybara.javascript_driver = :selenium_chrome_devtools
else
  Capybara.javascript_driver = :selenium_chrome_headless
end
