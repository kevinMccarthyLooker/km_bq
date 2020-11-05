connection: "snowlooker"

view: users {
  view_label: ""
  sql_table_name: public.users ;;
  parameter: date_aggregation {
    type: string
    default_value: "Day"
    allowed_value: {value: "Day"}
    allowed_value: {value: "Week"}
    allowed_value: {value: "Month"}
    allowed_value: {value: "Quarter"}
    allowed_value: {value: "Year"}
    description: "Date aggregation filter, used in conjunction with 'Build Date Aggregated'."
  }
  dimension_group: build {
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql: ${TABLE}.created_at ;;
  }
  dimension: build_date_aggregated {
    convert_tz: no
    type: date
    label_from_parameter: date_aggregation
    sql:
    CASE
    WHEN {% parameter date_aggregation %} = 'Day'
    THEN ${build_date::date}
    WHEN {% parameter date_aggregation %} = 'Week'
    THEN ${build_week::date}
    WHEN {% parameter date_aggregation %} = 'Month'
    THEN ${build_month::date}
    WHEN {% parameter date_aggregation %} = 'Quarter'
    THEN ${build_quarter::date}
    WHEN {% parameter date_aggregation %} = 'Year'
    THEN ${build_year::date}
    ELSE NULL
    END ;;
  }
  measure: count {type:count
    html:
    <div class = 'single-value-viz'>
    <table style="width:100%">
    <tr><div style="background-color:green; width=100%">1</div>
    </tr>
    <tr><div style="background-color:blue; width=100%">1</div>
    </tr>
    </table>
    </div>
    ;;
    }

  measure: count_drill {
    type: count
    drill_fields: [sort_hacker,build_month,build_date,age,count]
  }
  dimension: sort_hacker {
    type: date
    sql: current_date ;;
    order_by_field: age
    html: placeholder ;;
  }
  dimension: age {
    type: number
  }



}
explore: users2 {
  from: users
}

view: inventory_items {
  sql_table_name: public.inventory_items ;;
  dimension: product_brand {}
  filter: select_brand {}
  dimension: parameterized_logic {
    sql: case when {%condition select_brand %}${product_brand}{%endcondition%} then 'Matches Condition' else 'else case' end ;;
  }
  #add NOT somewhere in sql
  dimension: negated_parameterized_logic_added_not {
    sql: case when NOT {%condition select_brand %}${product_brand}{%endcondition%} then 'Does Not Match Condition is true' else 'else case' end ;;
  }
  #or leverage an else case instead
  dimension: negated_parameterized_logic_swapped_else {
    sql: case when {%condition select_brand %}${product_brand}{%endcondition%} then 'ignore' else 'leverage the else case' end ;;
  }
}
explore: inventory_items {}
