include: "/views/order_items__snowlooker.view"
include: "order_items_explore"

view: order_item_pop_helper {
  derived_table: {
    sql:
    select 'current' as version
    union all
    select 'prior' as version;;
  }
  dimension: version {}
}

explore: +order_items {
  join: order_item_pop_helper {
    sql:  left join order_item_pop_helper on (${order_items.created_raw}<=(select max(created_at) from public.order_items));;
#   type: cross
    relationship: many_to_one
  }
}


view: +order_items {
  dimension_group: created {
    label: "test"
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql:
    case when ${order_item_pop_helper.version} = 'current' then
    ${EXTENDED}
    else
      dateadd(Year,1,${EXTENDED})
    end

    ;;
  }

}
