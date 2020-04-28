connection: "thelook_events_redshift"

view: order_items {
  dimension: id {primary_key:yes}
  dimension_group: created {
    convert_tz: no
    type: time
    timeframes: [date]
    sql: ${TABLE}.created_at ;;
  }
  dimension_group: returned {
    convert_tz: no
    type: time
    timeframes: [date]
    sql: ${TABLE}.returned_at ;;
  }
  measure: count {
    #this will double count now
    type: count
  }

  measure: count_created {
    type: count
    filters: [dates_cross.version: "created_at"]
  }
  measure: count_returned {
    type: count
    filters: [dates_cross.version: "returned_at"]
  }
}

view: dates_cross {
  derived_table: {
    sql:
select 'created_at' as version
union all
select 'returned_at' as version
    ;;
  }
  dimension: version {primary_key:yes}

  dimension_group: the_date {
    convert_tz: no
    type: time
    timeframes: [date]
    sql: case when ${version} = 'created_at' then ${order_items.created_date} else ${order_items.returned_date} end;;
  }
}

explore: order_items {
  join: dates_cross {
    type: cross
    relationship: one_to_one
  }
}
