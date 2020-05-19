connection: "biquery_publicdata_standard_sql"


explore: test_refinements {}
view: test_refinements {
  derived_table: {sql: select 1 as test ;;}
  dimension: test {

  }
}
view: +test_refinements {
  dimension: test2 {

    sql: ${TABLE}.test ;;
  }

}

include: "/users.view"
view: test_parameter_ui {
  # extends: [users]
  sql_table_name: `lookerdata.thelook.users` ;;
  parameter: include_year_toggle {
    allowed_value: {value:"Include Year"}
    allowed_value: {value:"Don't Include Year"}
  }
  dimension: age {}
  measure: count {type:count}
}
explore: test_parameter_ui {}
