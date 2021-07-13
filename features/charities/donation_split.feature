Feature: Charities: donation split

Scenario: Donator splits their donation explicitly
  When a donator splits their donation unevenly among the charities
  Then the donation split should appear on their donations list
