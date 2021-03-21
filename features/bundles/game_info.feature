Feature: Bundles: game info

Scenario: Game info available from bundle description
  Given a bundle with the following games:
    | Game | Description               |
    | Halo | I guess he's in the navy? |
  When a donator clicks on "Halo" in the bundle definition
  Then they should see "Halo" and its description
