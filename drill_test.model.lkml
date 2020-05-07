connection: "thelook_events_redshift"

view: users {
  sql_table_name: public.users ;;
  dimension: id {primary_key:yes}
  measure: count {
    type: count
    drill_fields: [id]
  }
  measure: other_measure {
    type: count
    link: {
      url: "{{count._link}}"
      label: "test"
    }
    # html: {{count._rendered_value}} ;;#clickable on a bar chart
    html: <a href='#drillmenu' class='cell-clickable-content' target='_self'>{{count._rendered_value}}</a> ;;#clickable on a bar chart or table
  }
}

explore: users {
  label: "test label2"
}
