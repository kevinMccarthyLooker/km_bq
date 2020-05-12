connection: "thelook_events_redshift"

include: "/users.view.lkml"                # include all views in the views/ folder in this project

access_grant: test_access_grant {
  user_attribute: email
  allowed_values: ["kevin.mccarthy@looker.co"]
}
explore: users {
  required_access_grants: [test_access_grant]
}

view: test_ndt {
  derived_table: {
    explore_source: users {
      column: age {}
    }
  }
  dimension: age {}
}

explore: test_ndt {}
