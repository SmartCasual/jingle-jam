Feature: Donator accounts: after donation

Scenario: Anonymous donator is offered more login options
  When a donator makes a donation without giving a name or an email address
  Then they should be told that an email address is required

Scenario: Less anonymous donator is provided more login options less intrusively
  When a donator makes a donation giving an email address
  Then they are not offered the ability to set up more ways to access their account
  But they can provide that information via their account page
