connection: "biquery_publicdata_standard_sql"

#no adjustments to the standard users view
include: "/yoy_with_cross_join/users.view.lkml"                # include all views in the views/ folder in this project

#extremely simple to use with 'Version' as a pivot
#check out this explore
#https://profservices.dev.looker.com/explore/yoy_with_cross_join/users?qid=o2zLlGqBxnfFmdWhlDXlHR&toggle=fil
explore: users {
  #join to any explore, just need to update which field we refer to in YOY support (this could be a tny template)
  join: yoy_support {
    type:cross
    relationship:one_to_one
    #could do better/cleaarner here... but this is to not project today's data into the future and report rows of data a 'prior' for that future period
    sql_where: ${yoy_support.the_date}<(select max((CAST(TIMESTAMP(FORMAT_TIMESTAMP('%F %H:%M:%E*S', users.created_at , 'America/New_York')) AS DATE))) from `lookerdata.thelook.users` AS users);;
    }
}

view: yoy_support {
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
    case when ${version}='prior' then date_add(${users.created_date}, INTERVAL {{number._parameter_value}} {{timeframe._parameter_value}})
    else ${users.created_date}
    end
    ;;
  }
  parameter: number {
    type:number
    default_value: "1"
  }
  parameter: timeframe {
    type: unquoted
    allowed_value: {value:"Year"}
    allowed_value: {value:"Month"}
    default_value: "Year"
  }
  measure: validation_dates {
    type: string
    sql: 'actual date range included: '|| min(${users.created_date}) || ' to ' || max(${users.created_date}) ;;
  }
}
