view: order_items {
  sql_table_name: `lookerdata.thelook_web_analytics.order_items`
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

#   dimension: created_at {
#     type: string
#     sql: ${TABLE}.created_at ;;
#   }
  dimension_group: created {
    type: time
    timeframes: [date,month]
    sql: timestamp(${TABLE}.created_at) ;;
  }

#   dimension: delivered_at {
#     type: string
#     sql: ${TABLE}.delivered_at ;;
#   }

  dimension_group: delivered {
    type: time
    timeframes: [date,month]
    sql: timestamp(nullif(${TABLE}.delivered_at,'/N')) ;;
  }

  dimension: inventory_item_id {
    type: number
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: returned_at {
    type: string
    sql: ${TABLE}.returned_at ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension: shipped_at {
    type: string
    sql: ${TABLE}.shipped_at ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  measure: count {
    type: count
    drill_fields: [id]
  }
}
