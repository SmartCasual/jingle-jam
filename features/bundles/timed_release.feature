Feature: Bundles: timed release

@set-time:2022-10-15T00:00:01Z
Scenario: Tiers unlock if in date range
  Given a bundle with the following time-released tiers:
    | Game        | Tier | Starts at        | Ends at             |
    | Halo        | £25  | 2022-10-14 00:00 | 2022-10-16 23:59:59 |
    | The Witness | £25  | 2022-10-14 00:00 |                     |
    | Frogger     | £25  |                  | 2022-10-16 23:59:59 |
    | Minecraft   | £25  |                  |                     |
    | Hitman      | £25  | 2022-10-16 00:00 |                     |
    | Persona 5   | £25  |                  | 2022-10-14 23:59:59 |
    | Worms       | £25  | 2022-10-16 00:00 | 2022-10-17 23:59:59 |
  Then the dates for the tiers should be shown on the fundraiser page:
    | Games                  | Tier | Availability                                                     |
    | The Witness, Minecraft | £25  | Available now                                                    |
    | Frogger, Halo          | £25  | Available until 2022-10-16 23:59:59 (UTC)                        |
    | Worms                  | £25  | Available between 2022-10-16 00:00 (UTC) and 2022-10-17 23:59:59 (UTC) |
    | Hitman                 | £25  | Available from 2022-10-16 00:00 (UTC)                            |
    | Persona 5              | £25  | No longer available                                              |
  When a donator makes a £25 donation
  Then a key should be assigned for "Halo"
  And a key should be assigned for "The Witness"
  And a key should be assigned for "Frogger"
  And a key should be assigned for "Minecraft"
  And a key should not be assigned for "Hitman"
  And a key should not be assigned for "Persona 5"
  And a key should not be assigned for "Worms"
