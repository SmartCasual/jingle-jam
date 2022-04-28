Feature: Charities: donation split

Scenario: Donator splits their donation explicitly
  When a donator splits their donation unevenly among the charities
  Then the donation split should appear on their donations list

Scenario: Donator's split doesn't add up
  When a donator splits their donation in a way that doesn't add up to their total donation
  Then the donator should be asked to correct their split

@admin
Scenario: Regular admins cannot access the accounting page
  When the admin goes to the admin section
  Then they should not see the donation accounting section

@admin
@support
Scenario: Admin views aggregate donation splits
  Given a variety of split and unsplit donations
  Then the admin should be able to see a breakdown of amounts owed to each charity
