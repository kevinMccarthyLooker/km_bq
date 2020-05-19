connection: "snowlooker"

include: "/users.view"

view: +users {
  dimension_group: created {
    timeframes: [date,month,quarter]
    datatype: datetime
  }
  dimension: quarter {
    sql: ${created_quarter} ;;
    html:
    {{value}}
    {% assign year = value | split: '-' | first%}
    {% assign month = value | split: '-' | last%}
    {{month}}
    {% assign quarter_number = month | divided_by:3 | plus: 1%}
    {{year}} {{quarter_number}}
    ;;

  }
}

explore: users {}
