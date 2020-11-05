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
  dimension_group: created {
    type: time
    timeframes: [raw,date,month,year]
  }

}

explore: users {

  label: "test label2"
}

view: mess_with_dimension_in_dimension_group {
  extends: [users]
  # dimension: created_month {#ERRORED
  #   label: "test me!"
  # }
}
explore: mess_with_dimension_in_dimension_group {}

view: dynamic_unioned_source {
  filter: sources_to_include {
    suggestions: ["order_items","events"]
  }
  derived_table: {
    sql:
select 'order_items' as source_name, users.*, order_items.id as another_id_field from public.users left join order_items on users.id=order_items.user_id
where {%condition sources_to_include%}source_name{%endcondition%}
union all
select 'events' as source_name, users.*, events.id as another_id_field from public.users left join events on users.id=events.user_id
where {%condition sources_to_include%}source_name{%endcondition%}

    ;;
  }
  dimension: source_name {}
  measure: count {type:count}
}
explore: dynamic_unioned_source {}
