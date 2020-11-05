# ####### Cross Pop - Kevin McCarthy - Updated 7/4/2020

# ####### About PoP Method 9 aka Cross Pop: {
# # - Many Benefits of the other most comprehensive method, Method 8
# # - - Allows many periods
# # - - Allows several choices of period sizes
# # - - Uses a Pivot Field to hold different periods
# # - - Support multiple variations of Pop such as different base date fields, even within the same explore.
# # - Other Benefits of Method 9:
# # - - Layers on top of existing explores and reporting, not new explores and fields. Existing drills, etc, should play nice with cross pop
# # - - Very simple to maintain & scale: No derived table sql and measures do not need to be mentioned anywhere for them to work with POP
# # - - Intuitive for Users:  Has Period smart parameter defaulting
# #} End About

# ####### # Usage Notes: {
# # - Users will Pivot a particular field.
# # - - We'll be adding it to an existing field picker group for the date so it will be easy to find
# # - Users can, if desired, use parameters to override the default - show 1 prior period, and align period length to the selected date grain (i.e. 1 row offset)
# # - Cross Pop generates future periods for each date, which results 'future' periods appear in result set
# # - - While technically correct (i.e. Future's Prior Periods are happening now), it my be distracting
# # - -  Users can exclude these by using a filter like before today on the original created date
# #!!#, or can use the filter_future_period field defined below in the convenience fields section
# #} End Usage Notes

# ######### Implementation Explanation/Notes {
# # - This will be a refinement an existing view, which you may not have used before. See:https://docs.looker.com/data-modeling/learning-lookml/refinements
# # - - Your existing view can remain untouched & we will layer on this refinement by including it in the file where the explore is defined
# # - - Then, you will include this file above your explore definition, and add extends:[cross_pop_extention] to explores
# # - - If you want to remove pop or turn it off at any time, remove your line that includes the refinement
# # - Mostly, you will simply be updating references to update the date field name to match your date field
# # - - Lines you are expected to change are have ZERO indent in the lookml
# # - Date function logic will need to be adjusted based on dialect.  This example is redshift specific, such as:
# # - - dateadd([TIME-UNIT],[periods_ago],[date_field]) function, a bigquery connection would use DATE_ADD([date_field],interval periods_ago [TIME-UNIT]).
# # - - TIMEZONE conversion functions. To get the correct conversion function, carefully review the Looker generated sql on a date field, extracting the part that aligns timezones (not the truncate &/or cast for Looker formatting).
# #} End Implementation Explanation

# ######### Explanation of the technique {
# # The key concept here is we are fannout out data to create extra data sets for each prior period.  And we are then adding calendar time to those prior period datasets to re-align them to current date.
# ## dateadd(TIME-UNIT,ONE-OR-MORE-PERIODS-AGO-INTEGERS-GENERATED-BY-CROSS-JOIN,YOUR-ORIGINAL-DATE-SQL-FOR-THIS-FIELD)
# # Because of the re-aligned dates, all logic works just as before, as long as the the period name/number is pivotted (note that if it's not, we skip the date manipulation logic entirely)
# # The date logic looks significantly more complex, only because we have to apply timezone conversion manually (so it's done before date manipulation and re-grouping)
# #} End Explanation of the technique

# include: "/method1.view"
# include: "*method9_pop_support__template*" #includes some fields that are core to the PoP implementation and referenced below. Ensure you update to match the location where you put the pop_support view code

# view: +order_items {#!Update to point to your view name.  That view's file must be included here, and then THIS file must be included in the explore


#   dimension: datetime_unconverted {
#     convert_tz: no
#     hidden: yes
#     datatype: datetime
#     type: date_time
#     sql: WHERE_A_TIMESTAMP_WOULD_GO ;;
#   }
#   dimension: datetime_converted {
#     convert_tz: yes
#     hidden: yes
#     datatype: datetime
#     type: date_time
#     sql: WHERE_A_TIMESTAMP_WOULD_GO ;;
#   }

#   dimension: conversion_sql_start {
#     hidden: yes
#     sql:
#     {% assign char_conversion_start = "${datetime_unconverted}" | remove_first:'(' | split:'' | reverse | join:'' | remove_first:')' | split:'' | reverse | join:'' | split: "WHERE_A_TIMESTAMP_WOULD_GO" | first | strip %}
#     {% assign tz_converted_start_without_char_conversion_start = "${datetime_converted}" | remove_first:'(' | split:'' | reverse | join:'' | remove_first:')' | split:'' | reverse | join:'' | split: "WHERE_A_TIMESTAMP_WOULD_GO" | first | strip | remove_first: char_conversion_start %}
#     {{tz_converted_start_without_char_conversion_start}}
#     ;;
#   }
#   dimension: conversion_sql_end {
#     hidden: yes
#     sql:
#     {% assign char_conversion_end = "${datetime_unconverted}" | remove_first:'(' | split:'' | reverse | join:'' | remove_first:')' | split:'' | reverse | join:'' | split: "WHERE_A_TIMESTAMP_WOULD_GO" | last | strip %}
#     {% assign tz_converted_end_without_char_conversion_end = "${datetime_converted}"  | remove_first:'(' | split:'' | reverse | join:'' | remove_first:')' | split:'' | reverse | join:'' | split: "WHERE_A_TIMESTAMP_WOULD_GO" | last | strip | remove_first: char_conversion_end %}
#     {{tz_converted_end_without_char_conversion_end}}
#     ;;
#   }
#   dimension: my_dialect__add_minutes_format__expression {
#     hidden: yes
#     type: date_raw
#     expression: add_minutes(123456789,now());;
#   }
#   dimension: now__expression {
#     hidden: yes
#     type: date_raw
#     expression: now();;
#   }

#   # The following field, sets up Default Period Lengths to compare use for each of your timeframes
#   # - A SIMPLIFIED ALTERNATIVE: ... If you insted wanted to limit options and simplify UI
#   # - - Optional Simplify Step 1: Hardcode THIS field's sql to a single Period Length (E.g. sql:Month;; or sql:Year;;)
#   # - - Optional Simplify Step 2: Hide the pop parameters by adding the following refinement to above your explore to hide pop parameters: view: +pop_support{filter: periods_ago_to_include {hidden:yes}parameter: period_size {hidden:yes}}
#   # - If implementing PoP support on multiple dates in THIS view, insert corresponding _is_selected checks against all supported date fields here (For standard flexible usage, your code should check for lowest grain of each field before checking for next lowest grain of each field, and so on)
#   dimension: selected_period_size {
#     sql:
#       {% assign selected_period_size_sql = 'Year'%}{%comment%}if none of the anticipated dimensions were selected, we'll use year over year as default{%endcomment%}
#       {%if pop_support.period_size._parameter_value != 'Default'%}{% assign selected_period_size_sql = pop_support.period_size._parameter_value %}
#       {% else %}
#         {% if       created_date._is_selected %}{% assign selected_period_size_sql = 'Day'%}
#         {% elsif    created_week._is_selected %}{% assign selected_period_size_sql = 'Week'%}
#         {% elsif   created_month._is_selected %}{% assign selected_period_size_sql = 'Month'%}
#         {% elsif created_quarter._is_selected %}{% assign selected_period_size_sql = 'Quarter'%}
#         {% elsif    created_year._is_selected %}{% assign selected_period_size_sql = 'Year'%}
#         {% endif %}
#       {% endif %}
#       {{selected_period_size_sql}}
#       ;;
#   }

#   # Refine your base date field
#   # - Repoint this to your base field's name
#   dimension_group: created {
#     convert_tz: no #need to do timezone conversion before the date manipulation, so we can't use looker to do it the default way
# ####sql below utilizes expressions to generate correct date function syntax.  If this causes any issues, you may try this version (redshift) in place of the pop_logic in my dialect {
# #   {% if pop_support.periods_ago._in_query %}--PoP pivot found, so applying date addition to prior periods to align with current...
# #     {% assign date_add_interval_size__selected_period_size = selected_period_size._sql | strip %}--Period Size used according to user choice else default based on selected fields: {{date_add_interval_size__selected_period_size}}
# #     dateadd(
# #       {{date_add_interval_size__selected_period_size}},
# #       {{periods_to_add__to_align_past_period_with_current_period}},
# #       {{original_date_field_sql__with_timezone_conversion_sql_if_applicable}}
# #     ) #
# ##}end sql only version
#     sql:--setting variables...{% assign original_date_field_sql = '${EXTENDED}' | strip %}{%assign selected_time_period_size_sql = "${selected_period_size}"%}{% assign original_date_field_sql__with_timezone_conversion_sql_if_applicable = original_date_field_sql %}{% assign tz_size = _query._query_timezone | size %}
#       {% comment %}OPTIONALLY DELETE THIS TZ IF BLOCK TO SKIP ANY ATTEMPT TO DO TZ CONVERSIONS{% endcomment %}{% if tz_size > 0 %}--timezone settings found and are being manually re-applied...{% assign conversion_sql_start_sql = "${conversion_sql_start}" | remove_first:'(' | split:'' | reverse | join:'' | remove_first:')' | split:'' | reverse | join:'' | strip %}{% assign conversion_sql_end_sql = "${conversion_sql_end}" | remove_first:'(' | split:'' | reverse | join:'' | remove_first:')' | split:'' | reverse | join:''  | strip %}{% assign original_date_field_sql__with_timezone_conversion_sql_if_applicable = conversion_sql_start_sql | append: original_date_field_sql | append: conversion_sql_end_sql %}{% endif %}
#         {% if pop_support.periods_ago._in_query %}--PoP pivot found, so applying date addition to prior periods to align with current...first setting additional formula variables...{% assign my_dialect__add_minutes_format__sql = '${my_dialect__add_minutes_format__expression}' | remove_first:'(' | split:'' | reverse | join:'' | remove_first:')' | split:'' | reverse | join:'' | strip %}{% assign now__expression_sql = '${now__expression}' | remove_first:'(' | split:'' | reverse | join:'' | remove_first:')' | split:'' | reverse | join:'' | strip %}{% assign date_add_interval_size__selected_period_size = selected_period_size._sql | strip %}--Period Size used according to user choice else default based on selected fields: {{date_add_interval_size__selected_period_size}}
#         {% assign final_sql =  my_dialect__add_minutes_format__sql
#           | replace: 'minute', selected_time_period_size_sql
#           | replace: '123456789','pop_support.periods_ago'
#           | replace: now__expression_sql,original_date_field_sql__with_timezone_conversion_sql_if_applicable %}
#         {{final_sql}}
#         {% else %}{{original_date_field_sql__with_timezone_conversion_sql_if_applicable}}--Note: PoP pivot not _in_query, so PoP logic not applied{% endif %}
#         ;;
#   }

# # This is the field that people will select(pivot) to invoke POP.  We define it here rather than pop_support so we can add the group label and use the default we configured above
#   dimension: created_date_periods_ago_pivot {#!Update to match your base field name
#     label: "{% if _field._in_query%}Pop Period (Created {{selected_period_size._sql}}){%else%} Pivot for Period Over Period{%endif%}"#this complex label makes the 'PIVOT ME' instruction clear in the field picker but doesn't display it on output
#     group_label: "Created Date" #!Update this group label if necessary to make it fall in your date field's group_label
#     required_fields: [pop_support.periods_ago]
#     order_by_field: pop_support.periods_ago #sort numerically/chronologically.
#     sql:
#     CASE pop_support.periods_ago
#       WHEN 0 THEN ' Current'
#       WHEN 1 THEN pop_support.periods_ago || ' {{selected_period_size._sql | strip }} Prior'
#       ELSE        pop_support.periods_ago || ' {{selected_period_size._sql | strip }}s Prior'
#     END
#     ;;#should not need to update the sql
#   }

#   #Optional Validation Field. To use, paste your base date's original sql here
#   measure: pop_validation {
#     view_label: "PoP - VALIDATION - TO BE HIDDEN"
#     label: "Range of Raw Dates Included"
# #!Paste the sql parameter value from the original date fields as the variable value for base_sql
#     sql:{%assign base_sql = '${TABLE}.created_at'%}
#           min({{base_sql}})|| ' to '||max({{base_sql}})
#       ;;
#   }

# #   dimension: view_name {hidden:yes sql:{{_view._name}};;}#utilized to limiting 'future'

# }
