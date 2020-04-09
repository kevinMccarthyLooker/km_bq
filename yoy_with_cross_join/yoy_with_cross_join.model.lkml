connection: "biquery_publicdata_standard_sql"

#no adjustments to the standard users view
include: "/yoy_with_cross_join/users.view.lkml"                # include all views in the views/ folder in this project

#check out this explore
#https://profservices.dev.looker.com/explore/yoy_with_cross_join/users?qid=1GLLKk5MWaGLzqWoFrj8w4&toggle=fil
explore: users {
  join: yoy_support {type:cross relationship:one_to_one}
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
    timeframes: [date]
    sql:
    case when ${version}='prior' then date_add(${users.created_date}, INTERVAL 1 YEAR)
    else ${users.created_date}
    end
    ;;
  }
  measure: user_created_count_current {
    type: count_distinct
    sql:  ${users.id};;
    filters:[version: "current"]
  }
  measure: user_created_count_prior {
    type: count_distinct
    sql:  ${users.id};;
    filters:[version: "prior"]
  }
}
