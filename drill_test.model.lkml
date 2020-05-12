connection: "thelook_events_redshift"

view: users {
  sql_table_name: public.users ;;
  dimension: id {primary_key:yes}
  dimension: time_field {
    type: date
#     convert_tz: yes
    datatype: date
    sql: cast(created_at as date);;
  }
}

explore: users {

  label: "test label2"
}
