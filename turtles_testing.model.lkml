connection: "biquery_publicdata_standard_sql"

include: "/users.view.lkml"

explore: users {
  aggregate_table: rollup__country {
    query: {
      dimensions: [country]
      measures: [count]
      timezone: "America/New_York"
    }

    materialization: {
      persist_for: "12 hours"
    }
  }


}
