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

  parameter: code_set_1a__code_type {}
  parameter: code_set_1b__code_type {}
  parameter: code_set_1c__code_type {}
  parameter: code_set_1d__code_type {}
  parameter: code_set_2a__code_type {}
  parameter: code_set_2b__code_type {}
  parameter: code_set_2c__code_type {}
  parameter: code_set_2d__code_type {}
  parameter: code_set_3a__code_type {}
  parameter: code_set_3b__code_type {}
  parameter: code_set_3c__code_type {}
  parameter: code_set_3d__code_type {}


  filter: code_set_1a__code_values {}
  filter: code_set_1b__code_values {}
  filter: code_set_1c__code_values {}
  filter: code_set_1d__code_values {}
  filter: code_set_2a__code_values {}
  filter: code_set_2b__code_values {}
  filter: code_set_2c__code_values {}
  filter: code_set_2d__code_values {}
  filter: code_set_3a__code_values {}
  filter: code_set_3b__code_values {}
  filter: code_set_3c__code_values {}
  filter: code_set_3d__code_values {}


  dimension: age {}
  measure: count {type:count}
}
explore: test_parameter_ui {}
