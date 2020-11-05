view: users {
  sql_table_name: public.users ;;
  # derived_table: {
  #   sql: select * ;;
  # }
  dimension: age {
    type: number
  }
  measure: count {
    type: count
  }
}
explore: users {}
