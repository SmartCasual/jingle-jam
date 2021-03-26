Feature: Charities: charity info

Scenario: Charity info available from homepage
  Given the following charities:
    | Charity       | Description            |
    | Foster's Home | For imaginary friends. |
  When a donator clicks on "Foster's Home" on the homepage
  Then they should see the charity "Foster's Home" and its description
