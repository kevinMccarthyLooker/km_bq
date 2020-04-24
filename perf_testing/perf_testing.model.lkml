connection: "snowlooker"

view: snowlooker_events_big {
  derived_table: {
sql:

with x as
(
select 1 as days_added
{% for sequence_number in (2..100) %} union all select {{sequence_number}} as days_added {%endfor%}
/*union all
select 3 as years_added union all
select 4 as years_added union all
select 5 as years_added union all
select 6 as years_added union all
select 7 as years_added union all
select 8 as years_added union all
select 9 as years_added union all
select 10 as years_added
*/

)
select EVENTS.*,x.days_added,dateadd(day,days_added,created_at) as x_created_at from "PUBLIC"."EVENTS"
cross join x
;;
cluster_keys: ["user_id"]
persist_for: "24 hours"
  }
  measure: count {
    type: count

  }

  dimension: id {
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: sequence_number {
    type: number
    sql: ${TABLE}."SEQUENCE_NUMBER" ;;
  }

  dimension: session_id {
    type: string
    sql: ${TABLE}."SESSION_ID" ;;
  }

  dimension_group: created_at {
    type: time
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension: ip_address {
    type: string
    sql: ${TABLE}."IP_ADDRESS" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: zip {
    type: string
    sql: ${TABLE}."ZIP" ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}."LATITUDE" ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}."LONGITUDE" ;;
  }

  dimension: os {
    type: string
    sql: ${TABLE}."OS" ;;
  }

  dimension: browser {
    type: string
    sql: ${TABLE}."BROWSER" ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}."TRAFFIC_SOURCE" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: uri {
    type: string
    sql: ${TABLE}."URI" ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}."EVENT_TYPE" ;;
  }

  dimension: days_added {
    type: number
    sql: ${TABLE}."YEARS_ADDED" ;;
  }

  dimension_group: x_created_at {
    type: time
    sql: ${TABLE}."X_CREATED_AT" ;;
  }

  dimension: location {
    type: location
    sql_latitude: ${TABLE}."latitude" ;;
    sql_longitude: ${TABLE}."longitude" ;;
  }
}
include: "users.view"
include: "users_summary.view"
explore: snowlooker_events_big {
  join: users {
    relationship: many_to_one
    sql_on: ${snowlooker_events_big.user_id}=${users.id} ;;
  }

  join: users_summary {
    relationship: many_to_one
    sql_on: ${snowlooker_events_big.user_id}=${users_summary.user_id} ;;
  }
}
