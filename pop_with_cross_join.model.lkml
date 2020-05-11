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
    #could do better/cleaarner here... but this is to not project today's data into the future and report rows of data a 'prior' for that future period
    sql_where: ${pop_support.the_date}<(select max(${pop_support.the_date_for_sql_always_where}) from `lookerdata.thelook.users` AS users);;
    }
}
view: pop_support_users {
  extends: [pop_support]
  dimension: the_date_for_sql_always_where {
    type: date
    sql: ${users.created_date::datetime} ;;
  }
}
view: pop_support {
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
    timeframes: [date,month,year]
    sql:
    case when ${version}='prior' then date_add(${users.created_date}, INTERVAL {{timeframes_to_offset_by._parameter_value}}
    {% if the_date._in_query %} Day
    {% elsif the_month._in_query %} Month
    {% elsif the_year._in_query %} Year
    {%endif%}
    )
    else ${users.created_date}
    end
    ;;
    #{{offset_timeframe._parameter_value}}
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
    sql: 'actual date range included: '|| min(${users.created_date}) || ' to ' || max(${users.created_date}) ;;
  }
}
