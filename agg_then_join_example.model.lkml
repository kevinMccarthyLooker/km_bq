connection: "thelook_events_redshift"

view: users {
  sql_table_name: public.users ;;
  dimension: id {primary_key:yes}
  dimension: city {}
  dimension: state {}
  dimension: country {}
  dimension: zip {}
  dimension: month {
    type: date_month
    sql: ${TABLE}.created_at ;;
  }
}
explore: users {hidden:yes}
view: events {
  sql_table_name: public.events ;;
  dimension: id {primary_key:yes}
  dimension: city {}
  dimension: state {}
  dimension: country {}
  dimension: zip {}
  dimension: month {
    type: date_month
    sql: ${TABLE}.created_at ;;
  }
}
explore: events {hidden:yes}

view: users_ndt {
  derived_table: {
    explore_source: users {
      column: id {}
      column: city {}
      column: state {}
      column: country {}
      column: zip {}
      column: month {}
    }
  }
  dimension: id {primary_key:yes}
  dimension: city {}
  dimension: state {}
  dimension: country {}
  dimension: zip {}
  dimension: month {}
}
view: events_ndt {
  derived_table: {
    explore_source: events {
      column: id {}
      column: city {}
      column: state {}
      column: country {}
      column: zip {}
      column: month {}
    }
  }
  dimension: id {primary_key:yes}
  dimension: city {}
  dimension: state {}
  dimension: country {}
  dimension: zip {}
  dimension: month {}
}
# events_x as (
#   select *, DATE_TRUNC('month', CONVERT_TIMEZONE('UTC', 'America/New_York', created_at )) as month from public.events
#   where {%condition month%}events.created_at{%endcondition%}
#   and {%condition state%}events.state{%endcondition%}
# )
# ,users_x as (select *, DATE_TRUNC('month', CONVERT_TIMEZONE('UTC', 'America/New_York', created_at )) as month from public.users
#   where {%condition month%}users.created_at{%endcondition%}
#   and {%condition state%}users.state{%endcondition%}
# )
view: agg_then_join_example {
  derived_table: {
    sql:

--available dimensions to try (exist on both datasets)
-- 'city,
-- state,
-- country,
-- zip,
-- month --calculations added in prep step... _x
-- '

--
--events_x as (select *, DATE_TRUNC('month', CONVERT_TIMEZONE('UTC', 'America/New_York', created_at )) as month from public.events where created_at > '2020-01-02')
with
--prep tables... need calculations to be performed here so we can simply refer to column names below
events_x as (
  select * from ${events_ndt.SQL_TABLE_NAME}
  where {%if month._is_filtered%}{%condition month%}events_ndt.month{%endcondition%}{%endif%}
  {%if state._is_filtered%}and {%condition state%}events_ndt.state{%endcondition%}{%endif%}
)
,users_x as (select * from ${users_ndt.SQL_TABLE_NAME}
  where {%if month._is_filtered%}{%condition month%}users_ndt.month{%endcondition%}{%endif%}
  {%if state._is_filtered%}and {%condition state%}users_ndt.state{%endcondition%}{%endif%}
)

{% assign source_table_1 = 'events_x'%}
{% assign source_table_2 = 'users_x'%}


{%assign selected_dimensions =''%}
{% if month._in_query %}{%assign selected_dimensions = selected_dimensions | append: 'month,' %}{%endif%}
{% if state._in_query %}{%assign selected_dimensions = selected_dimensions | append: 'state,' %}{%endif%}
{%assign selected_dimensions = selected_dimensions | split: "" | reverse | join: "" |replace_first:',','' | split: "" | reverse | join: ""%}


--processing...
{%assign selected_dimensions_stripped = selected_dimensions | strip_newlines %}
--Selection after stripped: {{selected_dimensions_stripped}}
{%assign x = selected_dimensions_stripped | split: ','%}
{% assign selected_dimensions_source_1 = ''%}
{% assign selected_dimensions_source_2 = ''%}
{% assign selected_dimensions_coalesced = ''%}
{% assign selected_dimensions_coalesced_for_group_by_no_as = ''%}
{%for field in x %}
  {%assign selected_dimensions_source_1 = selected_dimensions_source_1 | append: source_table_1 | append: '.' | append: field | append:',' %}
  {%assign selected_dimensions_source_2 = selected_dimensions_source_2 | append: source_table_2 | append: '.' | append: field | append:',' %}
  {%assign selected_dimensions_coalesced = selected_dimensions_coalesced | append: 'coalesce(' | append: source_table_1 | append: '_data' | append: '.' | append: field | append:',' | append: source_table_2 | append: '_data' | append: '.' | append: field | append: ') as ' | append: field | append:',' %}
  {%assign selected_dimensions_coalesced_for_group_by_no_as = selected_dimensions_coalesced_for_group_by_no_as | append: 'coalesce(' | append: source_table_1 | append: '.' | append: field | append:',' | append: source_table_2 | append: '.' | append: field | append: ')' | append:',' %}
{%endfor%}
{%assign selected_dimensions_coalesced_for_group_by_no_as_length = selected_dimensions_coalesced_for_group_by_no_as | size | times:1 %}
{%assign selected_dimensions_coalesced_for_group_by_no_as = selected_dimensions_coalesced_for_group_by_no_as | split: "" | reverse | join: "" |replace_first:',','' | split: "" | reverse | join: ""%}

--subquery for the first source
,{{source_table_1}}_data as (
select
1 as support,
{{selected_dimensions_source_1}}
count(*) as events
from {{source_table_1}}
group by {{selected_dimensions_source_1}}
support
)
--subquery for the second source
,{{source_table_2}}_data as (
select
2 as support,
{{selected_dimensions_source_2}}
count(*) as users
from {{source_table_2}}
group by
{{selected_dimensions_source_2}}
support
)
--full outer join on false the two subqueries
, Final_Query as
(
select
{{selected_dimensions_coalesced}}
{{source_table_1}}_data.events,
{{source_table_2}}_data.users

from
{{source_table_1}}_data
full outer join {{source_table_2}}_data on {{source_table_1}}_data.support={{source_table_2}}_data.support
)
select
{{selected_dimensions}}
,
sum(events) as event_count,
sum(users) as user_count
from final_query
group by {{selected_dimensions}}
order by {{selected_dimensions}}
    ;;
  }

  dimension:month {
    type: date_month
    sql: ${TABLE}.month ;;
  }
  dimension: state {
    sql: {% if state._is_selected%}state{%else%}{%endif%} ;;
  }

  measure: event_count {
    type: sum
    sql: ${TABLE}.event_count ;;
  }
  measure: user_count {
    type: sum
    sql: ${TABLE}.user_count ;;
  }

}
explore: agg_then_join_example {
}
