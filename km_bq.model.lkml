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
