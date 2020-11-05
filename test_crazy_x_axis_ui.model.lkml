connection: "snowlooker"

view: users {
  sql_table_name: public.users ;;
  dimension: country {
    html:
<table style="width:100%"><tr><td>
<div>{{rendered_value}}</div></td><div style="width:100%"> <details><summary style="outline:none">
</summary> Value: {{count._rendered_value}}
</details>
  </div></tr></table>;;
  }
  measure: count {
    type: count
  }

dimension: country_2 {
  html:

  <div></div><div style="width:100%"> <details><summary style="outline:none">{{rendered_value}}
  </summary> Value: {{count._rendered_value}}
  </details>
    </div>;;
    sql: ${TABLE}.country ;;
}

}
explore: users {}
