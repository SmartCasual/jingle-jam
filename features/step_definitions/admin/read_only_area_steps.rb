Given(/^a (bundle|donation|donator)$/) do |model_name|
  @current_model = FactoryBot.create(model_name)
end

Then(/^the (bundle|donation|donator)'s (\w+) should appear on the admin (?:bundle|donation|donator)s? list$/) do |model_name, attribute|
  go_to_admin_area model_name.humanize.pluralize
  expect(page).to have_css("td.col-#{attribute}", text: @current_model.send(attribute))
end

When(/^the user goes to the admin (bundle|donation|donator)s? area$/) do |model_name|
  visit(send("admin_#{model_name}s_path"))
end
