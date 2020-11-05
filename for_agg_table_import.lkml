# Place in `test_agg_awareness_refinement_errors` model
include: "explore_for_import"
explore: +users {
  aggregate_table: rollup__age {
    query: {
      dimensions: [age]
      measures: [count]
    }
    ##Rfwe

    materialization: {
      persist_for: "24 hours"
    }
  }
}
