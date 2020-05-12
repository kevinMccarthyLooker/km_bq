connection: "snowlooker"

include: "events.view"

# view: +events {
#   parameter: audience {
#     suggest_explore: audience_suggestions
#     suggest_dimension: audience
#   }
# }

view: audience {
  derived_table: {
    #would need to explicitly create columns for each possible filter
    sql:
select 'a' as audience, 'UK' as country_filter, null as sequence_number_filter, null as browser_filter union all
select 'b' as audience, 'USA' as country_filter, 1 as sequence_number_filter , null as browser_filter
    ;;
    persist_for: "24 hours"
  }
  parameter: audience_selection {suggest_persist_for:"0 seconds"}
  dimension: audience {hidden:yes}
  dimension: country_filter {hidden:yes}
  dimension: sequence_number_filter {hidden:yes}
  dimension: browser_filter {hidden:yes}
}
explore: audience_suggestions {
  from: audience
}

explore: events {
  join: audience {
    relationship: one_to_one
    type: inner
    #sql and 1=1 for readability
    #would need to explicitly list out all possible filters, and maintain...
    #using position search to enable audience table fields to contain lists not individual entries
    #coalesce so that it works on unused filter fields (which we'll populate as null)
    #the position logic didn't work in the numeric field sequence number..
    sql_on: 1=1
  and position(coalesce(${audience.country_filter},${events.country}),${events.country})>0
  and position(coalesce(${audience.browser_filter},${events.browser}),${events.browser})>0

  and ${events.sequence_number} = coalesce(${audience.sequence_number_filter},${events.sequence_number})
  and {%condition audience.audience_selection%}audience.audience{%endcondition%}
    ;;
  }

}
