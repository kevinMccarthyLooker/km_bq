connection: "biquery_publicdata_standard_sql"

include: "users.view"
include: "events.view"

include: "//dau_wau_mau_support__remote_dependency/monthly_active_users_template"
view: +monthly_active_users_config {
  dimension: activation_event__input_date_field {sql:${events.created_date};;}
  dimension: user_id__input_field {sql:${events.user_id};;}
  dimension: activation_event__criteria {sql:${events.event_type}<>'Cancel' and ${events.event_type}<>'Test';;}

#testing
  measure: dates_list {
#     type: list
#     list_field: activation_event__input_date_field
# {{dates_list2._value | date:"%s"| minus: thirty_days_in_seconds | date: "%Y-%m-%d" %}
# {% assign thirty_days_in_seconds = 30 | times: seconds_in_a_day %}
    type: string
    sql: STRING_AGG(DISTINCT cast(${activation_event__input_date_field} as string), ' ')  ;;
    html:
    {% assign seconds_in_a_day = 24 | times: 60 | times: 60 %}
    {% assign twenty_nine_days_in_seconds = 29 | times: seconds_in_a_day %}
    <details><summary>Dates Included: {{ dates_list2._value | date:"%s"| minus: twenty_nine_days_in_seconds | date: "%Y-%m-%d" }} to {{ dates_list2._value }}... (Expand for Dates Found With Activations)</summary>
    {%assign found_dates = value | split:' '%}
    <span style="font-size:0.8em">

    {% assign x = dates_list2._value %}
    {% for i in (0...29)%}
      {%if i == 10 %}<br>{%endif%}
      {%if i == 20 %}<br>{%endif%}
      {% assign days_in_seconds = i | times: seconds_in_a_day %}
      {% assign included_date = x | date:"%s"| minus: days_in_seconds | date: "%Y-%m-%d" %}
      {% assign included_date_string = included_date | append:"" %}
      {%assign was_found = false %}
      {%for check in found_dates%}
        {%if check == included_date_string %}{%assign was_found = true %}{%endif%}
      {%endfor%}
      {%if was_found %}<span style="color:green; font-weight:bold">{%else%}<span>{%endif%}
      {{included_date_string | date:"%m-%d"}}
      </span>
    {%endfor%}
    </span>
    </details>
    ;;
#
#     {{x}}
#
  }
  measure: dates_list2 {
    type: string
    sql: max(${monthly_active_users_config.monthly_active_users_measurement_date}) ;;
    html:
    {% assign seconds_in_a_day = 24 | times: 60 | times: 60 %}
    {%assign x = value %}
    {{x}}

    {% for i in (1...30)%}
      {% assign days_in_seconds = i | times: seconds_in_a_day %}
      {{ x | date:"%s"| minus: days_in_seconds | date: "%Y-%m-%d" }}
    {%endfor%}
    ;;
  }
# {% assign seconds = 5 | times: 24 | times: 60 | times: 60 %}
# {{ date | date: "%s" | plus: seconds | date: "%Y-%m-%d" }}
}

explore: events {
  extends: [monthly_active_users_explore_extender]
}
