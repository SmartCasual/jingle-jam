Feature: Charities: charity info

Scenario: Charity info available from fundraiser page
  Given the following charities:
    | Charity       | Description            | Fundraiser         |
    | Foster's Home | For imaginary friends. | Imaginary telethon |
  When a donator clicks on "Foster's Home" on the "Imaginary telethon" fundraiser page
  Then they should see the charity "Foster's Home" and its description
