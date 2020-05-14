# connection: "biquery_publicdata_standard_sql"
# connection: "thelook_events_redshift"
connection: "snowlooker"
#currently only works with snowlfake cause of the hardcoded timezone handling

include: "users.view.lkml"
view: +users {
  dimension_group: created {
    timeframes: [date,week,month,quarter,year] #other timeframes like time or day of year not supported
    convert_tz: no # timeszones needed to be pushed down before offsetting dates.  I pasted the timezone conversion logic directly for now...
    sql:
    {% if pop_support_user_created_date.version._in_query %}
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
}

explore: users {
  join: pop_support_user_created_date {
    relationship:one_to_one
    sql: left join pop_support_user_created_date on ${users.created_date}<=(select max(CONVERT_TIMEZONE('UTC', 'America/New_York', cast(created_at as timestamp_ntz))) as max_created from public.users);;
  }

#queries to get users started with pop
  query: week_over_week{
    dimensions: [created_week,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Week", users.created_date_timeframes_to_offset_by: "1"]
    measures: [count]
  }
  query: month_over_month{
    dimensions: [created_month,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Month", users.created_date_timeframes_to_offset_by: "1"]
    measures: [count]
  }
  query: quarter_over_quarter{
    dimensions: [created_quarter,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Quarter", users.created_date_timeframes_to_offset_by: "1"]
    measures: [count]
  }
  query: year_over_year{
    dimensions: [created_year,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Year", users.created_date_timeframes_to_offset_by: "1"]
    measures: [count]
  }
  query: daily_vs_one_week_prior{
    dimensions: [created_date,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Week", users.created_date_timeframes_to_offset_by: "1"]
    measures: [count]
  }
  query: daily_vs_one_year_prior__calendar_date{
    dimensions: [created_date,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Year", users.created_date_timeframes_to_offset_by: "1"]
    measures: [count]
  }
  query: daily_vs_one_year_prior__52_weeks{
    dimensions: [created_date,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Week", users.created_date_timeframes_to_offset_by: "52"]
    measures: [count]
  }
  query: weekly_vs_one_year_prior{
    description: "group data by week and compare to the 7 days that are one year prior to that week's days"
    dimensions: [created_week,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Year", users.created_date_timeframes_to_offset_by: "1"]
    measures: [count]
  }
  query: weekly_vs_52_weeks_prior{
    description: "group data by week and compare to the week that was 52 weeks prior to that week. Differs slightly from YOY by calendar days"
    dimensions: [created_week,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Week", users.created_date_timeframes_to_offset_by: "52"]
    measures: [count]
  }
  query: monthly_vs_12_months_prior{
    description: "group data by week and compare to the week that was 52 weeks prior to that week. Differs slightly from YOY by calendar days"
    dimensions: [created_month,created_date_current_vs_prior_period]
    pivots: [created_date_current_vs_prior_period]
    filters: [users.created_date_pop_offset_timeframe_size: "Month", users.created_date_timeframes_to_offset_by: "12"]
    measures: [count]
  }
}
