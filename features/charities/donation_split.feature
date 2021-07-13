Feature: Charities: donation split

Scenario: Donator splits their donation explicitly
  When a donator splits their donation unevenly among the charities
  Then the donation split should appear on their donations list

@admin
Scenario: Regular admins cannot access the accounting page
  When the admin goes to the admin section
  Then they should not see the donation accounting section

@admin
@support
Scenario: Admin views aggregate donation splits
  Given a variety of split and unsplit donations
  Then the admin should be able to see a breakdown of amounts owed to each charity
