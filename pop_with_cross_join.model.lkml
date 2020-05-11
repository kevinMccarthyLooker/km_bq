connection: "biquery_publicdata_standard_sql"

#no adjustments to the standard users view
include: "/yoy_with_cross_join/users.view.lkml"                # include all views in the views/ folder in this project

#extremely simple to use with 'Version' as a pivot
#check out this explore
#https://profservices.dev.looker.com/explore/yoy_with_cross_join/users?qid=o2zLlGqBxnfFmdWhlDXlHR&toggle=fil
explore: users {
  #join to any explore, just need to update which field we refer to in YOY support (this could be a tny template)
  join: pop_support {
    from: pop_support_users
    type:cross
    relationship:one_to_one
    sql_where: ${pop_support.the_date}<=(select max(${pop_support.input__the_date_to_pop}) from {{pop_support.input__the_original_source_table._sql}} AS {{pop_support.input__the_original_source_table_view_name._sql}});;
    }
}
view: pop_support_users {
  extends: [pop_support]

  dimension: input__the_date_to_pop {
    type: date
    #use the desired date field
    sql: ${users.created_date::date} ;;
  }
  dimension: input__the_original_source_table {sql: `lookerdata.thelook.users` ;;}
  dimension: input__the_original_source_table_view_name {sql: users ;;}
}

###don't need to modify
view: pop_support {
  dimension: input__the_date_to_pop {
    # hidden:yes #hide later
    convert_tz: no
    # type: date
    sql: WILL BE OVERRIDEN IN EXTENSION ;;
  }
  dimension: input__the_original_source_table {sql: `lookerdata.thelook.users` ;; }# hidden:yes #hide later
  dimension: input__the_original_source_table_view_name {sql: users ;; }# hidden:yes #hide later

  derived_table: {
    sql:
select 'current' as version
union all
select 'prior' as version ;;
  }
  dimension: version {}
  dimension_group: the {
    type: time
    datatype: date
    convert_tz: no
    timeframes: [date,month,year]
    sql:
    case when ${version}='prior' then date_add(${input__the_date_to_pop}, INTERVAL {{timeframes_to_offset_by._parameter_value}}
    {% if the_date._in_query %} Day
    {% elsif the_month._in_query %} Month
    {% elsif the_year._in_query %} Year
    {%endif%}
    )
    else ${input__the_date_to_pop}
    end
    ;;
  }

#removed this in favor of in_query magic
#   parameter: offset_timeframe {
#     type: unquoted
#     allowed_value: {value:"Year"}
#     allowed_value: {value:"Month"}
#     default_value: "Year"
#   }
  parameter: timeframes_to_offset_by {
    type:number
    default_value: "1"
  }
  measure: validation_dates {
    type: string
    sql: 'actual date range included: '|| min(${input__the_date_to_pop}) || ' to ' || max(${input__the_date_to_pop}) ;;
  }
}
