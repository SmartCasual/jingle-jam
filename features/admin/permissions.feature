Feature: Admin: Permissions

Scenario: Viewing permissions
  Given the admin has individual permissions
  Then a list of the permissions appears on the admin users page
  When the admin is given full access
  Then the permissions list shows "Full access"

Scenario: editing permissions
  Given an admin with no permissions
  And an admin with permission to manage users
  Then the managing admin should be able to grant the other admin new permissions
  And the managing admin should be able to remove permissions from the other admin
