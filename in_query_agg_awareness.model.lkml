connection: "biquery_publicdata_standard_sql"

view: users_USA {
  derived_table: {
    sql:select * from `lookerdata.thelook_event_extract_201701.users`  where country='USA';;
  }
  dimension: age {}
  dimension: country {}
  measure: count {type:count}
}

view: users_UK {
  derived_table: {
    sql:select * from `lookerdata.thelook_event_extract_201701.users`  where country='UK';;
  }
  dimension: age {}
  dimension: country {}
  measure: count {type:count}
}

view: users_dynamic_source {
  derived_table: {
    # {%if _filters['country_select']=="'UK'" %}
    # x:{{x}}
    sql: select * from
    {%assign x = _filters['country_select']}}%}

    {%if x == 'USA' %}
    ${users_USA.SQL_TABLE_NAME}
    {%elsif x == 'UK' %}
    ${users_UK.SQL_TABLE_NAME}
    {%else%}`lookerdata.thelook_event_extract_201701.users`
    {%endif%}
    ;;

  }
  dimension: age {}
  dimension: country {}
  measure: count {type:count}
  filter: country_select {
    suggestions: ["USA","UK"]
  }

}
explore: users_dynamic_source {}



view: use_filters {derived_table: {sql: select '{{_filters['users.country']}}' as filter_value;;}}
view: users {
  sql_table_name: `lookerdata.thelook_event_extract_201701.users` ;;
  dimension: country {}
  measure: count {type:count}
  measure: leverage_filters {
    type: number
    sql: case when  (select filter_value from ${use_filters.SQL_TABLE_NAME}) = 'UK' then ${count}*1.5 else max(1) end ;;
  }
}
explore: users {}
