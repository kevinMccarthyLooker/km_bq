connection: "thelook_events_redshift"

view: users {
  sql_table_name: public.users ;;
  dimension: id {primary_key:yes}
  dimension: age {type:number}
  measure: count {type:count}
}
explore: users {
  access_filter: {
    field: age
    user_attribute: number_filter_advanced_test
  }
}
