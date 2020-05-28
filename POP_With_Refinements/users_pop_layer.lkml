include: "/users.view.lkml"
include: "/POP_With_Refinements/users_explore.lkml"
view: +users {
#   dimension: table2 {
#     sql:{% if pop_support_user_created_date._in_query %}{%assign out = "case when version = 'current' then users"%}{%else%}{%assign out = "users"%}{%endif%}{{out}};;
#     }
  dimension: field_end {
#     sql:{% if pop_support_user_created_date._in_query %}{%assign output = 'else null end'%}
#       {%else%}{%assign output = ''%}{%endif%}{{output}};;
}
  dimension_group: created {
    timeframes: [date,week,month,quarter,year] #other timeframes like time or day of year not supported
    convert_tz: no # timeszones needed to be pushed down before offsetting dates.  I pasted the timezone conversion logic directly for now...
#     {% if pop_support_user_created_date.version._in_query %}
    sql:
    {% if pop_support_user_created_date._in_query %}
    case when pop_support_user_created_date.version='prior' then
    {%if _dialect._name == 'bigquery_standard_sql'%}date_add(CONVERT_TIMEZONE('UTC', 'America/New_York', cast(${EXTENDED} as timestamp_ntz)), INTERVAL {{created_date_timeframes_to_offset_by._parameter_value}} {{created_date_pop_offset_timeframe_size._parameter_value}})
    {%elsif _dialect._name == 'redshift'%}dateadd({{created_date_pop_offset_timeframe_size._parameter_value}},{{created_date_timeframes_to_offset_by._parameter_value}},CONVERT_TIMEZONE('UTC', 'America/New_York', cast(${EXTENDED} as timestamp_ntz)))
    {%elsif _dialect._name == 'snowflake'%}dateadd({{created_date_pop_offset_timeframe_size._parameter_value}},{{created_date_timeframes_to_offset_by._parameter_value}},CONVERT_TIMEZONE('UTC', 'America/New_York', cast(${EXTENDED} as timestamp_ntz)))
    {%else%} UNSUPPORTED DIALECT!  UPDATE WITH LOGIC SIMILAR TO THAT SHOWN ABOVE FOR OTHER DIALECTS
    {%endif%}
    else CONVERT_TIMEZONE('UTC', 'America/New_York', cast(${EXTENDED} as timestamp_ntz))
    end
    {% else %}CONVERT_TIMEZONE('UTC', 'America/New_York', cast(${EXTENDED} as timestamp_ntz))
    {%endif%}
    ;;
  }
  dimension: created_date_current_vs_prior_period {
    hidden: yes #bring em forth with turtles?
    view_label: "Users - Created Date POP"
    description: "add me to pivot"
    required_fields: [pop_support_user_created_date.version]
    sql: case when ${pop_support_user_created_date.version}='prior' then 'Offset By {{created_date_timeframes_to_offset_by._parameter_value}} {{created_date_pop_offset_timeframe_size._parameter_value}}' else 'current' end ;;
  }
  #adding these parameters here instead of in a pop view helps in that their use doesn't trigger the fannout.  Only using the field that requires pop.version causes that join to happen.
  parameter: created_date_timeframes_to_offset_by {
    hidden: yes #bring em forth with turtles?
    view_label: "Users - Created Date POP"
    label: "Config POP 1 - Enter an Offset Number"
    type:number
    default_value: "1"
  }
  parameter: created_date_pop_offset_timeframe_size {
    hidden: yes #bring em forth with turtles?
    view_label: "Users - Created Date POP"
    label: "Config POP 2 - Enter an Offset Grain"
    type: unquoted
    allowed_value: {value:"Day"}
    allowed_value: {value:"Week"}
    allowed_value: {value:"Month"}
    allowed_value: {value:"Quarter"}
    allowed_value: {value:"Year"}
    default_value: "Year"
  }
}
#gets called by 'required fields' that we added
view: pop_support_user_created_date {
  derived_table: {
    sql:
    select 'current' as version
    union all
    select 'prior' as version ;;
  }
  dimension: version {hidden:yes}
}#

view: users_measures_prior {
  sql_table_name: users ;;
  dimension: table2 {sql:case when version = 'prior' then users;;}
  dimension: field_end {type:date_raw sql:--
    else null end;;}
  extends: [users]
}
explore: +users {
  join: pop_support_user_created_date {

    relationship:one_to_one
    sql: left join pop_support_user_created_date on ${users.created_date}<=(select max(CONVERT_TIMEZONE('UTC', 'America/New_York', cast(created_at as timestamp_ntz))) as max_created from public.users);;
  }
  join: users_measures_prior {
    required_joins: [pop_support_user_created_date]
    fields: [users_measures_prior.all_measures*]
    sql:  ;;
    relationship: one_to_one
  }

#queries to get users started with pop
  query: user_created_week_over_week{
    dimensions: [created_week,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Week", users.created_date_timeframes_to_offset_by: "1"]
    measures: [count]
  }
  query: user_created_month_over_month{
    dimensions: [created_month,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Month", users.created_date_timeframes_to_offset_by: "1"]
    measures: [count]
  }
  query: user_created_quarter_over_quarter{
    dimensions: [created_quarter,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Quarter", users.created_date_timeframes_to_offset_by: "1"]
    measures: [count]
  }
  query: user_created_year_over_year{
    dimensions: [created_year,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Year", users.created_date_timeframes_to_offset_by: "1"]
    measures: [count]
  }
  query: user_created_daily_vs_one_week_prior{
    dimensions: [created_date,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Week", users.created_date_timeframes_to_offset_by: "1"]
    measures: [count]
  }
  query: user_created_daily_vs_one_year_prior__calendar_date{
    dimensions: [created_date,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Year", users.created_date_timeframes_to_offset_by: "1"]
    measures: [count]
  }
  query: user_created_daily_vs_one_year_prior__52_weeks{
    dimensions: [created_date,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Week", users.created_date_timeframes_to_offset_by: "52"]
    measures: [count]
  }
  query: user_created_weekly_vs_one_year_prior{
    description: "group data by week and compare to the 7 days that are one year prior to that week's days"
    dimensions: [created_week,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Year", users.created_date_timeframes_to_offset_by: "1"]
    measures: [count]
  }
  query: user_created_weekly_vs_52_weeks_prior{
    description: "group data by week and compare to the week that was 52 weeks prior to that week. Differs slightly from YOY by calendar days"
    dimensions: [created_week,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Week", users.created_date_timeframes_to_offset_by: "52"]
    measures: [count]
  }
  query: user_created_monthly_vs_12_months_prior{
    description: "group data by week and compare to the week that was 52 weeks prior to that week. Differs slightly from YOY by calendar days"
    dimensions: [created_month,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Month", users.created_date_timeframes_to_offset_by: "12"]
    measures: [count]
  }
  query: lifetime_events_for_cohort_vs_12_months_prior_cohort{
    label: "z_last_example: Lifetime Events For Cohort Vs 12 Months Prior Cohort"
    description: "group data by week and compare to the week that was 52 weeks prior to that week. Differs slightly from YOY by calendar days"
    dimensions: [created_month,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Month", users.created_date_timeframes_to_offset_by: "12"]
    measures: [events.count]
  }
}
