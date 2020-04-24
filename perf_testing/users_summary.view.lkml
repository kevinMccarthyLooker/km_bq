view: users_summary {
derived_table: {
  sql:
select user_id,min(events.created_at) as first_event from ${snowlooker_events_big.SQL_TABLE_NAME} as events group by 1
  ;;
}
dimension: user_id {}
dimension: first_event {
  type: date_time
}
}
