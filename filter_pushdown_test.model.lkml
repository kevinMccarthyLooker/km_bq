connection: "biquery_publicdata_standard_sql"

# include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/view.lkml"                   # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
# explore: order_items {
#   join: orders {
#     relationship: many_to_one
#     sql_on: ${orders.id} = ${order_items.order_id} ;;
#   }
#
#   join: users {
#     relationship: many_to_one
#     sql_on: ${users.id} = ${orders.user_id} ;;
#   }
# }


view: order_items {
  sql_table_name: `lookerdata.thelook_web_analytics.order_items` ;;
  dimension: user_id {}
  dimension: created_date{type:date sql:${TABLE}.created_at;;datatype:date}
  dimension: id {primary_key:yes}
  measure: count {type:count}
}
view: users {
#   sql_table_name: `lookerdata.thelook_web_analytics.users` ;;
  derived_table: {
    sql:
    select * from `lookerdata.thelook_web_analytics.users`
    ;;
  }

  dimension: id {primary_key:yes}
  dimension: created_date{type:date sql:${TABLE}.created_at;;datatype:date}
  measure: count {type:count}
}

explore: order_items {
  join: users {
    relationship: many_to_one
    sql_table_name: (select * from users) ;;
    sql_on: ${order_items.user_id}=${users.id} ;;
  }
}
