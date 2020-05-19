view: users {
  dimension: primary_key {primary_key:yes sql:${id};;}
  dimension: table2 {sql:${TABLE} ;;}
  # dimension: table3 {sql:{% assign t3 = 'tt123' %};;}
  dimension: field_end { sql:--;;}
  dimension: field_end_length {sql:;;}

  sql_table_name:
  {% if _dialect._name == 'bigquery_standard_sql' %}`lookerdata.thelook.users`
  {% elsif _dialect._name == 'redshift'%}public.users
  {% elsif _dialect._name == 'snowflake'%}public.users
  {%endif%}
    ;;
  drill_fields: [id]

  dimension: id {
    type: number
    sql: {{users.table2._sql}}.id ;;
  }

  dimension: age {
    type: number
    #getting an error with the pased through text being evaluated as liquid
    # sql:
    # {% assign field_endZ = "${field_end}" | remove_first: '(' | split: "" | reverse | join: "" | remove_first: ')' | split: "" | reverse | join: "" %}
    # {% assign table_adjustment = "${table2}" | remove_first: '(' | split: "" | reverse | join: "" | remove_first: ')' | split: "" | reverse | join: "" %}
    # {{table_adjustment}}.age{{field_endZ}};;
  }


  dimension: city {
    type: string
    sql: {{users.table2._sql}}.city ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: {{users.table2._sql}}.country ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: email {
    type: string
    sql: {{users.table2._sql}}.email ;;
  }

  dimension: first_name {
    type: string
    sql: {{users.table2._sql}}.first_name ;;
  }

  dimension: gender {
    type: string
    sql: {{users.table2._sql}}.gender ;;
  }

  dimension: last_name {
    type: string
    sql: {{users.table2._sql}}.last_name ;;
  }

  dimension: referral_source {
    type: string
    sql: {{users.table2._sql}}.referral_source ;;
  }

  dimension: state {
    type: string
    sql: {{users.table2._sql}}.state ;;
  }

  dimension: zip {
    type: zipcode
    sql: {{users.table2._sql}}.zip ;;
  }

  measure: count {
    type: sum
#     filters: []
    sql:  case when ${id} is not null then 1 else null end;;
    drill_fields: [id, last_name, first_name]
  }
  measure: sum_age_test {
    type: sum
    sql: ${age} ;;
  }
  set: all_measures {fields:[count,sum_age_test]}
}
