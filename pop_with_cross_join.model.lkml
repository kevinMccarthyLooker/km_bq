# connection: "biquery_publicdata_standard_sql"
# connection: "thelook_events_redshift"
connection: "snowlooker"

#no adjustments to the standard users view
# include: "/yoy_with_cross_join/users.view.lkml"                # include all views in the views/ folder in this project
include: "users.view.lkml"

#extremely simple to use with 'Version' as a pivot
#check out this explore
#https://profservices.dev.looker.com/explore/pop_with_cross_join/users?qid=lDnFRgp9jlOaprqY0XGlKu&toggle=fil
explore: users {
  #join to any explore, just need to update which field we refer to in YOY
  join: pop_support_users {
    type:cross
    relationship:one_to_one
    sql_where: ${pop_support_users.the_date}<=(select max(${pop_support_users.input__the_date_to_pop}) from {{pop_support_users.input__the_original_source_table._sql}} AS {{pop_support_users.input__the_original_source_table_view_name._sql}});;
  }
}
view: pop_support_users {
  extends: [pop_support]
  dimension: input__the_date_to_pop {
    type: date
    sql: ${users.created_date::date} ;; #input the desired date field to use for period comparison.  fully qualify with view name (view name used in the original explore)
  }
  ##{for excluding most recent period being presented forward beyond the last original data (causes confusing UI)...
  #would like to improve these or make it automatic, but haven't found a way yet.
  dimension: input__the_original_source_table_view_name {sql: users ;;}
  dimension: input__the_original_source_table {
    #looker sample data lives in two different table names for our diffferent dialects
    sql:
    {% if _dialect._name == 'bigquery_standard_sql' %}`lookerdata.thelook.users`
    {% elsif _dialect._name == 'redshift'%}public.users
    {% elsif _dialect._name == 'snowflake'%}public.users
    {%endif%}
    ;;
  }
  ## }end... for excluding most recent period
}

###Implementers don't need to modify the code below... ####
view: pop_support {
  dimension: input__the_date_to_pop {# hidden:yes #hide later
    convert_tz: no
    sql: WILL BE OVERRIDEN IN EXTENSION ;;
  }
  dimension: input__the_original_source_table {sql: WILL BE OVERRIDEN IN EXTENSION ;; }# hidden:yes #hide later
  dimension: input__the_original_source_table_view_name {sql: WILL BE OVERRIDEN IN EXTENSION ;;}# hidden:yes #hide later

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
{% assign timeframe_to_offset_by = 'Day'%}
{% if the_date._in_query %} {% assign timeframe_to_offset_by = 'Day'%}
{% elsif the_month._in_query %} {% assign timeframe_to_offset_by = 'Month'%}
{% elsif the_year._in_query %} {% assign timeframe_to_offset_by = 'Year'%}
{%endif%}

case when ${version}='prior' then
  {%if _dialect._name == 'bigquery_standard_sql'%}date_add(${input__the_date_to_pop}, INTERVAL {{timeframes_to_offset_by._parameter_value}} {{timeframe_to_offset_by}})
  {%elsif _dialect._name == 'redshift'%}dateadd({{timeframe_to_offset_by}},{{timeframes_to_offset_by._parameter_value}},${input__the_date_to_pop})
  {%elsif _dialect._name == 'snowflake'%}dateadd({{timeframe_to_offset_by}},{{timeframes_to_offset_by._parameter_value}},${input__the_date_to_pop})
  {%else%} UNSUPPORTED DIALECT!  UPDATE WITH LOGIC SIMILAR TO THAT SHOWN ABOVE FOR OTHER DIALECTS
  {%endif%}
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
