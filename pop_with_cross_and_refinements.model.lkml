# connection: "biquery_publicdata_standard_sql"
# connection: "thelook_events_redshift"
connection: "snowlooker"

include: "users.view.lkml"
view: +users {
  dimension_group: created {
    sql:
    {% assign timeframe_to_offset_by = 'Day'%}
    {% assign looker_timeframe_suffix = _field._name | split: "_" | last  %}

    {% if looker_timeframe_suffix == 'Date' %} {% assign timeframe_to_offset_by = 'Day'%}
    {% elsif looker_timeframe_suffix == 'Week' %} {% assign timeframe_to_offset_by = 'Week'%}
    {% elsif looker_timeframe_suffix == 'Month' %} {% assign timeframe_to_offset_by = 'Month'%}
    {% elsif looker_timeframe_suffix == 'Quarter' %} {% assign timeframe_to_offset_by = 'Quarter'%}
    {% elsif looker_timeframe_suffix == 'Year' %} {% assign timeframe_to_offset_by = 'Year'%}
    {%endif%}

    {% if pop_support_users.version._in_query %}
    case when ${pop_support_users.version}='prior' then
    {%if _dialect._name == 'bigquery_standard_sql'%}date_add(${EXTENDED}, INTERVAL {{pop_support_users.timeframes_to_offset_by._parameter_value}} {{timeframe_to_offset_by}})
    {%elsif _dialect._name == 'redshift'%}dateadd({{timeframe_to_offset_by}},{{pop_support_users.timeframes_to_offset_by._parameter_value}},${EXTENDED})
    {%elsif _dialect._name == 'snowflake'%}dateadd({{timeframe_to_offset_by}},{{pop_support_users.timeframes_to_offset_by._parameter_value}},${EXTENDED})
    {%else%} UNSUPPORTED DIALECT!  UPDATE WITH LOGIC SIMILAR TO THAT SHOWN ABOVE FOR OTHER DIALECTS
    {%endif%}
    else ${EXTENDED}
    end
    {% else %}${EXTENDED}
    {%endif%}
     ;;
  }
  dimension: future_period {
    type: yesno
    sql:${created_date}>(select max(created_at) from public.users);;#wish we could do better here
  }
}

explore: users {
  join: pop_support_users {
    relationship:one_to_one
    sql: {%if pop_support_users.version._in_query%}cross join pop_support_users{% endif %} ;;
    sql_where: ${users.future_period} = 'No';;
  }
}
view: pop_support_users {
  derived_table: {
    sql:
    select 'current' as version
    union all
    select 'prior' as version ;;
  }
  dimension: version {}
  parameter: timeframes_to_offset_by {
    type:number
    default_value: "1"
  }

}
# #
# # ###Implementers don't need to modify the code below... ####
# view: pop_support {
# #   dimension: input__the_date_to_pop {hidden:yes #hide later
# #     convert_tz: no
# #     sql: WILL BE OVERRIDEN IN EXTENSION ;;
# #   }
# #   dimension: input__the_original_source_table {sql: WILL BE OVERRIDEN IN EXTENSION ;; hidden:yes}# hidden:yes #hide later
# #   dimension: input__the_original_source_table_view_name {sql: WILL BE OVERRIDEN IN EXTENSION ;; hidden:yes}# hidden:yes #hide later
#
#   derived_table: {
#     sql:
#     select 'current' as version
#     union all
#     select 'prior' as version ;;
#   }
#   dimension: version {}
#   parameter: timeframes_to_offset_by {
#     type:number
#     default_value: "1"
#   }
# #   dimension_group: analysis {
# #     type: time
# #     datatype: date
# #     timeframes: [date,week,month,quarter,year]
# #     sql:
# #     {% assign timeframe_to_offset_by = 'Day'%}
# #     {% if analysis_date._in_query %} {% assign timeframe_to_offset_by = 'Day'%}
# #     {% elsif analysis_quarter._in_query %} {% assign timeframe_to_offset_by = 'Quarter'%}
# #     {% elsif analysis_month._in_query %} {% assign timeframe_to_offset_by = 'Month'%}
# #     {% elsif analysis_year._in_query %} {% assign timeframe_to_offset_by = 'Year'%}
# #     {%endif%}
# #
# #     case when ${version}='prior' then
# #       {%if _dialect._name == 'bigquery_standard_sql'%}date_add(${input__the_date_to_pop}, INTERVAL {{timeframes_to_offset_by._parameter_value}} {{timeframe_to_offset_by}})
# #       {%elsif _dialect._name == 'redshift'%}dateadd({{timeframe_to_offset_by}},{{timeframes_to_offset_by._parameter_value}},${input__the_date_to_pop})
# #       {%elsif _dialect._name == 'snowflake'%}dateadd({{timeframe_to_offset_by}},{{timeframes_to_offset_by._parameter_value}},${input__the_date_to_pop})
# #       {%else%} UNSUPPORTED DIALECT!  UPDATE WITH LOGIC SIMILAR TO THAT SHOWN ABOVE FOR OTHER DIALECTS
# #       {%endif%}
# #     else ${input__the_date_to_pop}
# #     end
# #         ;;
# #   }
# #   dimension: future_period {
# #     type: yesno
# #     sql:${pop_support_users.analysis_date}>(select max(${pop_support_users.input__the_date_to_pop}) from {{pop_support_users.input__the_original_source_table._sql}} AS {{pop_support_users.input__the_original_source_table_view_name._sql}});;
# #   }
# #removed this in favor of in_query magic
# #   parameter: offset_timeframe {
# #     type: unquoted
# #     allowed_value: {value:"Year"}
# #     allowed_value: {value:"Month"}
# #     default_value: "Year"
# #   }
# #   parameter: timeframes_to_offset_by {
# #     type:number
# #     default_value: "1"
# #   }
# #   measure: validation_dates {
# #     type: string
# #     sql: 'actual date range included: '|| min(${input__the_date_to_pop}) || ' to ' || max(${input__the_date_to_pop}) ;;
# #   }
# }
