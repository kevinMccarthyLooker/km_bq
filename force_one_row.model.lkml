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
