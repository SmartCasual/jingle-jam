@admin
@manages_users
Feature: Admin: users

Scenario: Adding an admin user
  When an admin adds an admin user
  Then the admin user should appear on the admin users list
  And there should be an admin page for that admin user

Scenario: Editing an admin user
  Given an admin user
  When an admin edits the admin user
  Then the edits to the admin user should've been saved

Scenario: Deleting an admin user
  Given an admin user
  When an admin deletes the admin user
  Then the admin user shouldn't appear on the admin users list
