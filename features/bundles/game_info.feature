Feature: Bundles: game info

Scenario: Game info available from bundle description
  Given a bundle with the following games:
    | Game | Description               |
    | Halo | I guess he's in the navy? |
  When a donator clicks on "Halo" in the bundle description
  Then they should see the game "Halo" and its description
