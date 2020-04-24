connection: "thelook_events_redshift"

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
with
--prep tables... need calculations to be performed here so we can simply refer to column names below
events_x as (select *, TO_CHAR(DATE_TRUNC('month', CONVERT_TIMEZONE('UTC', 'America/New_York', created_at )), 'YYYY-MM') as month from public.events where created_at > '2020-01-02')
,users_x as (select *, TO_CHAR(DATE_TRUNC('month', CONVERT_TIMEZONE('UTC', 'America/New_York', created_at )), 'YYYY-MM') as month from public.users where created_at > '2020-01-02')

{% assign source_table_1 = 'events_x'%}
{% assign source_table_2 = 'users_x'%}


--configure selected fields.  This would be driven by is_selected checks
{%assign selected_dimensions =
'
month,
state
'
%}

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
-- events_data.*,
-- user_creation_data.*,
{{selected_dimensions_coalesced}}
-- coalesce(events_data.city,user_creation_data.city) as city,
-- coalesce(events_data.country,user_creation_data.country) as country,
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

  dimension:month {}
}
explore: agg_then_join_example {}
