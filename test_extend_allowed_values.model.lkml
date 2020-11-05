connection: "biquery_publicdata_standard_sql"

#fails because of extending a multiple item param
# view: a {
#   parameter: test {
#     allowed_value: {
#       value: "1"
#     }
#   }
# }

# view: b {
#   extends: [a]
#   parameter: test {
#     allowed_value: {
#       value: "2"
#     }
#   }
# }

# view: a {
#   sql_table_name: public.users ;;
#   dimension: age {}
#   filter: filter_field {type:date}
#   dimension: test_link {
#     sql: '1' ;;
#     # link: {
#     #   label: "test1"
#     #   url: "http://google.com/?{{ _filters['a.filter_field'] }}"
#     # }
#     link: {
#       label: "test2"
#       url: "http://google.com/?{{ _filters['a.filter_field'] | url_encode }}"
#     }
#     link: {
#       label: "test3"
#       url: "http://google.com/?{{ value | url_encode }}"
#     }
#   }
#
# }


# view: a {
#     sql_table_name: public.users ;;
#   dimension: city {}
# }

view: a {
#   sql_table_name: public.users ;;
  derived_table: {sql: select 1 as id;;}
  dimension: id {primary_key:yes}
  measure: special {
    allow_approximate_optimization: yes
    type: count_distinct
    sql: ${id} ;;
  }
}
view: b {
  derived_table: {sql:select 1 as test;;}
  dimension: test {primary_key:yes}
}

explore: a {
#   sql_always_where: '{{_user_attributes['name']}}'='Kevin McCarthy' ;;
  join: b {
    relationship: one_to_many
    type: left_outer
    sql_on: 1=1 ;;
  }
  aggregate_table: rollup__b_test {
    query: {
      dimensions: [b.test]
      measures: [special]
      timezone: "America/New_York"
    }

    materialization: {
      persist_for: "24 hours"
    }
  }
}
