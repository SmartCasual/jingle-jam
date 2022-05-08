Feature: Admin: read only areas

@admin
@support
Scenario Outline: Listing a <model>
  Given a <model>
  Then the <model>'s <attribute> should appear on the admin <model> list

  Examples:
    | model          | attribute |
    | donator bundle | id        |
    | donation       | message   |
    | donator        | name      |

@anonymous
Scenario Outline: Anonymous user cannot access this area
  When the user goes to the admin <model> area
  Then they should be bounced to the admin login page

  Examples:
    | model          |
    | donator bundle |
    | donation       |
    | donator        |

@donator
Scenario Outline: Known donator cannot access this area
  When the user goes to the admin <model> area
  Then they should be bounced to the admin login page

  Examples:
    | model          |
    | donator bundle |
    | donation       |
    | donator        |
