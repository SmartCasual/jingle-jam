Feature: Admin: 2SV

Scenario: 2SV is required for all admin users
  Given an admin user without 2SV enabled
  When the admin user tries to log in
  Then they should be redirected to set up 2SV
  When they set up 2SV
  Then the admin should be able to log in
