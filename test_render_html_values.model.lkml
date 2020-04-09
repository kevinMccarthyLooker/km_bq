connection: "biquery_publicdata_standard_sql"


view: test{
  derived_table: {
    sql: select '<a href="https://google.com/">link text</a>' as field ;;
  }
  dimension: test1 {
    sql: '1' ;;
    html: '<a href="https://google.com/">link text</a>' ;;
  }
  dimension: test2 {
    sql: ${TABLE}.field ;;
    html:{{value }}
    {% assign x = value %}
    {{x}}
    ;;
  }


}

explore: test {}
