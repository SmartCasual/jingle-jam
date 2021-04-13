@admin
Feature: Admin: access

@anonymous
Scenario: Anonymous user cannot access this area
  When the user goes to the admin users area
  Then they should be bounced to the admin login page

@donator
Scenario: Known donator cannot access this area
  When the user goes to the admin users area
  Then they should be bounced to the admin login page

Scenario: A normal admin cannot access protected areas
  Given at least one of each type of thing
  Then the admin should be able to see public information
  * the admin should be able to comment on public information
  * the admin should be able to see their own information
  * the admin should not be able to modify public information
  * the admin should not be able to read donation information
  * the admin should not be able to manage admin accounts

@data_entry
Scenario: A data entry admin can manage public information
  Given at least one of each type of thing
  Then the admin should be able to see public information
  * the admin should be able to comment on public information
  * the admin should be able to see their own information
  * the admin should be able to modify public information
  * the admin should not be able to read donation information
  * the admin should not be able to manage admin accounts

@support
Scenario: A support admin can access donation information
  Given at least one of each type of thing
  Then the admin should be able to see public information
  * the admin should be able to comment on public information
  * the admin should be able to see their own information
  * the admin should not be able to modify public information
  * the admin should be able to read donation information
  * the admin should not be able to manage admin accounts

@manages_users
Scenario: A user-management admin can manage admin accounts
  Given at least one of each type of thing
  Then the admin should be able to see public information
  * the admin should be able to comment on public information
  * the admin should be able to see their own information
  * the admin should not be able to modify public information
  * the admin should not be able to read donation information
  * the admin should be able to manage admin accounts

@data_entry
@support
Scenario: A multiple-role admin can access multiple areas
  Given at least one of each type of thing
  Then the admin should be able to see public information
  * the admin should be able to comment on public information
  * the admin should be able to see their own information
  * the admin should be able to modify public information
  * the admin should be able to read donation information
  * the admin should not be able to manage admin accounts

@full_access
Scenario: A full-access admin can do anything
  Given at least one of each type of thing
  Then the admin should be able to see public information
  * the admin should be able to comment on public information
  * the admin should be able to see their own information
  * the admin should be able to modify public information
  * the admin should be able to read donation information
  * the admin should be able to manage admin accounts
