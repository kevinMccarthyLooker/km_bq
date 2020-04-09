view: suggestions_view {
  sql_table_name: ${eav_sample_data.SQL_TABLE_NAME} ;;
  dimension: my_column_name_field {
    sql: column_name ;;
  }
  dimension: column_value_field {
    sql: column_value ;;
  }
}

view: main {
  sql_table_name: ${eav_sample_data.SQL_TABLE_NAME} ;;
  parameter: selector {
    type:string
    suggest_explore: suggestions
    suggest_dimension: suggestions.my_column_name_field
  }
  dimension: values_for_selector {
    sql: {% parameter selector %} ;;
  }

  dimension: primary_key {
    primary_key: yes
    sql: ${customer}||${schema_id}||${entity_id}||${column_id} ;;
  }
  measure: count {type:count}

  dimension: customer {
    type: string
    sql: ${TABLE}.customer ;;
  }

  dimension: schema_id {
    type: number
    sql: ${TABLE}.schema_id ;;
  }

  dimension: entity_id {
    type: number
    sql: ${TABLE}.entity_id ;;
  }

  dimension: column_id {
    type: number
    sql: ${TABLE}.column_id ;;
  }

  dimension: column_name {
    type: string
    sql: ${TABLE}.column_name ;;
  }

  dimension: column_value {
    label: "{% if _field._in_query %}{{selector._parameter_value | replace: \"'\",'' }}{%else%}Column Value{%endif %}"
    type: number
    sql: ${TABLE}.column_value ;;
  }

}


view: eav_sample_data {
  label: "EAV Sample Data"
  derived_table: {
    sql_trigger_value: SELECT DATE(CONVERT_TZ(NOW(), 'UTC', 'US/Pacific')) ;;

    sql: SELECT 'Columbia' as customer, 1 as schema_id, 1 as entity_id, 1 as column_id, 'sale_price' as column_name, 150 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'dollars' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 1 as entity_id, 2 as column_id, 'item_count' as column_name, 3 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'count' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 1 as entity_id, 3 as column_id, 'cost' as column_name, 70 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'dollars' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 1 as entity_id, 4 as column_id, 'gross_margin' as column_name, 80 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'dollars' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 1 as entity_id, 5 as column_id, 'retail_price' as column_name, 200 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'dollars' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 1 as entity_id, 6 as column_id, 'discount_rate' as column_name, 0.25 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'percentage' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 1 as entity_id, 7 as column_id, 'store_outlet' as column_name, 0 as column_value, 'Target' as column_string_value, cast(null as date) as column_date_value, 'string' as data_type, 'string' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 2 as entity_id, 8 as column_id, 'purchase_date' as column_name, 0 as column_value, null as column_string_value, cast('2018-06-28' as date) as column_date_value, 'date' as data_type, 'time' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 2 as entity_id, 1 as column_id, 'sale_price' as column_name, 300 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'dollars' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 2 as entity_id, 2 as column_id, 'item_count' as column_name, 5 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'count' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 2 as entity_id, 3 as column_id, 'cost' as column_name, 200 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'dollars' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 2 as entity_id, 4 as column_id, 'gross_margin' as column_name, 100 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'dollars' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 2 as entity_id, 5 as column_id, 'retail_price' as column_name, 600 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'dollars' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 2 as entity_id, 6 as column_id, 'discount_rate' as column_name, 0.5 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'percentage' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 2 as entity_id, 7 as column_id, 'store_outlet' as column_name, 0 as column_value, 'Walmart' as column_string_value, cast(null as date) as column_date_value, 'string' as data_type, 'string' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 2 as entity_id, 8 as column_id, 'purchase_date' as column_name, 0 as column_value, null as column_string_value, cast('2018-07-01' as date) as column_date_value, 'date' as data_type, 'time' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 2 as schema_id, 3 as entity_id, 1 as column_id, 'zip_code' as column_name, 68124 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'zipcode' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 2 as schema_id, 3 as entity_id, 2 as column_id, 'sale_price' as column_name, 460 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'dollars' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 2 as schema_id, 3 as entity_id, 3 as column_id, 'cost' as column_name, 200 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'dollars' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 2 as schema_id, 3 as entity_id, 4 as column_id, 'mall_location_name' as column_name, 0 as column_value, 'Westroads Mall' as column_string_value, cast(null as date) as column_date_value, 'string' as data_type, 'string' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 2 as schema_id, 3 as entity_id, 8 as column_id, 'purchase_date' as column_name, 0 as column_value, null as column_string_value, cast('2018-07-07' as date) as column_date_value, 'date' as data_type, 'time' as value_format  UNION ALL
          SELECT 'Calvin Klein' as customer, 3 as schema_id, 4 as entity_id, 1 as column_id, 'items_ordered' as column_name, 7 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'count' as value_format  UNION ALL
          SELECT 'Calvin Klein' as customer, 3 as schema_id, 4 as entity_id, 2 as column_id, 'cost' as column_name, 646 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'dollars' as value_format  UNION ALL
          SELECT 'Calvin Klein' as customer, 3 as schema_id, 4 as entity_id, 3 as column_id, 'product_categories' as column_name, 3 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'count' as value_format  UNION ALL
          SELECT 'Calvin Klein' as customer, 3 as schema_id, 4 as entity_id, 4 as column_id, 'number_on_sale' as column_name, 4 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'count' as value_format  UNION ALL
          SELECT 'Calvin Klein' as customer, 3 as schema_id, 4 as entity_id, 5 as column_id, 'sale_price' as column_name, 950 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'dollars' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 4 as schema_id, 5 as entity_id, 1 as column_id, 'What is your favorite product' as column_name, 0 as column_value, 'sweater' as column_string_value, cast(null as date) as column_date_value, 'free_response' as data_type, 'string' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 4 as schema_id, 5 as entity_id, 2 as column_id, 'What is your montly budget for spend on clothing' as column_name, 100 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'numerical' as data_type, 'dollars' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 4 as schema_id, 5 as entity_id, 3 as column_id, 'We are your favorite brand' as column_name, 0 as column_value, 'agree' as column_string_value, cast(null as date) as column_date_value, 'multiple_choice' as data_type, 'string' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 4 as schema_id, 5 as entity_id, 4 as column_id, 'Do you plan to purchase clothing as a gift this year' as column_name, 0 as column_value, 'yes' as column_string_value, cast(null as date) as column_date_value, 'multiple_choice' as data_type, 'string' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 4 as schema_id, 5 as entity_id, 5 as column_id, 'Where do you purchase the majority of your clothing' as column_name, 0 as column_value, 'our website' as column_string_value, cast(null as date) as column_date_value, 'multiple_choice' as data_type, 'string' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 4 as schema_id, 5 as entity_id, 6 as column_id, 'Rate your customer experience on a scale from 0 to 10 where 10 is best' as column_name, 9 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'numerical' as data_type, 'count' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 4 as schema_id, 6 as entity_id, 1 as column_id, 'What is your favorite product' as column_name, 0 as column_value, 'jacket' as column_string_value, cast(null as date) as column_date_value, 'free_response' as data_type, 'string' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 4 as schema_id, 6 as entity_id, 2 as column_id, 'What is your montly budget for spend on clothing' as column_name, 70 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'numerical' as data_type, 'dollars' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 4 as schema_id, 6 as entity_id, 3 as column_id, 'We are your favorite brand' as column_name, 0 as column_value, 'neutral' as column_string_value, cast(null as date) as column_date_value, 'multiple_choice' as data_type, 'string' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 4 as schema_id, 6 as entity_id, 4 as column_id, 'Do you plan to purchase clothing as a gift this year' as column_name, 0 as column_value, 'no' as column_string_value, cast(null as date) as column_date_value, 'multiple_choice' as data_type, 'string' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 4 as schema_id, 6 as entity_id, 5 as column_id, 'Where do you purchase the majority of your clothing' as column_name, 0 as column_value, 'Amazon' as column_string_value, cast(null as date) as column_date_value, 'multiple_choice' as data_type, 'string' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 4 as schema_id, 6 as entity_id, 6 as column_id, 'Rate your customer experience on a scale from 0 to 10 where 10 is best' as column_name, 6 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'numerical' as data_type, 'count' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 7 as entity_id, 1 as column_id, 'sale_price' as column_name, 74 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'dollars' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 7 as entity_id, 2 as column_id, 'item_count' as column_name, 1 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'count' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 7 as entity_id, 3 as column_id, 'cost' as column_name, 40 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'dollars' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 7 as entity_id, 4 as column_id, 'gross_margin' as column_name, 34 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'dollars' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 7 as entity_id, 5 as column_id, 'retail_price' as column_name, 110 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'dollars' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 7 as entity_id, 6 as column_id, 'discount_rate' as column_name, 0.33 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'decimal' as data_type, 'percentage' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 7 as entity_id, 7 as column_id, 'store_outlet' as column_name, 0 as column_value, 'REI Sports' as column_string_value, cast(null as date) as column_date_value, 'string' as data_type, 'string' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 1 as schema_id, 7 as entity_id, 8 as column_id, 'purchase_date' as column_name, 0 as column_value, null as column_string_value, cast('2018-07-05' as date) as column_date_value, 'date' as data_type, 'time' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 4 as schema_id, 8 as entity_id, 1 as column_id, 'What is your favorite product' as column_name, 0 as column_value, 'jacket' as column_string_value, cast(null as date) as column_date_value, 'free_response' as data_type, 'string' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 4 as schema_id, 8 as entity_id, 2 as column_id, 'What is your montly budget for spend on clothing' as column_name, 41 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'numerical' as data_type, 'dollars' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 4 as schema_id, 8 as entity_id, 3 as column_id, 'We are your favorite brand' as column_name, 0 as column_value, 'disagree' as column_string_value, cast(null as date) as column_date_value, 'multiple_choice' as data_type, 'string' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 4 as schema_id, 8 as entity_id, 4 as column_id, 'Do you plan to purchase clothing as a gift this year' as column_name, 0 as column_value, 'yes' as column_string_value, cast(null as date) as column_date_value, 'multiple_choice' as data_type, 'string' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 4 as schema_id, 8 as entity_id, 5 as column_id, 'Where do you purchase the majority of your clothing' as column_name, 0 as column_value, 'Malls' as column_string_value, cast(null as date) as column_date_value, 'multiple_choice' as data_type, 'string' as value_format  UNION ALL
          SELECT 'Columbia' as customer, 4 as schema_id, 8 as entity_id, 6 as column_id, 'Rate your customer experience on a scale from 0 to 10 where 10 is best' as column_name, 8 as column_value, null as column_string_value, cast(null as date) as column_date_value, 'numerical' as data_type, 'count' as value_format    ;;
  }

#   dimension: customer {
#     type: string
#     sql: ${TABLE}.customer ;;
#   }
#
#   dimension: schema_id {
#     type: number
#     sql: ${TABLE}.schema_id ;;
#   }
#
#   dimension: entity_id {
#     type: number
#     sql: ${TABLE}.entity_id ;;
#   }
#
#   dimension: column_id {
#     type: number
#     sql: ${TABLE}.column_id ;;
#   }
#
#   dimension: column_name {
#     type: string
#     sql: ${TABLE}.column_name ;;
#   }
#
#   dimension: column_value {
#     type: number
#     sql: ${TABLE}.column_value ;;
#   }
#
#   dimension: column_string_value {
#     type: string
#     sql: ${TABLE}.column_string_value ;;
#   }
#
#   dimension: column_date_value {
#     type: string
#     sql: ${TABLE}.column_date_value ;;
#   }
#
#   dimension: data_type {
#     type: string
#     sql: ${TABLE}.data_type ;;
#   }
#
#   dimension: value_format {
#     type: string
#     sql: ${TABLE}.value_format ;;
#   }
#
#   set: detail {
#     fields: [
#       customer,
#       schema_id,
#       entity_id,
#       column_id,
#       column_name,
#       column_value,
#       column_string_value,
#       column_date_value,
#       data_type,
#       value_format
#     ]
#   }
}
