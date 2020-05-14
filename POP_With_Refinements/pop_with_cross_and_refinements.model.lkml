
# connection: "biquery_publicdata_standard_sql"
# connection: "thelook_events_redshift"
connection: "snowlooker"
#currently only works with snowlfake cause of the hardcoded timezone handling
include: "users_explore"
include: "users_pop_layer"
explore: +users {}
