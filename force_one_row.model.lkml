connection: "biquery_publicdata_standard_sql"

view: base {
  derived_table: {sql:select 1;;}
  dimension: base {}
}
view: users {
  sql_table_name:  `lookerdata.thelook.users` ;;
  dimension: age {type:number}
  dimension: city {}
  dimension: id {primary_key:yes}
}

explore: force_one_row {
  from: base
  join: users {
    type: full_outer
    sql_on: 1=0 ;;
    relationship: one_to_one
    sql_where: 1=1 ;;
  }
  sql_always_where: 1=1) or (${users.id} is null ;;
}


view: test_dates {
  derived_table: {
    sql: select TIMESTAMP("2008-12-25 05:30:00+00") as current_date ;;
  }
  dimension: current_date {
    type: date_time
    datatype: timestamp
  }
}
explore: test_dates {}
