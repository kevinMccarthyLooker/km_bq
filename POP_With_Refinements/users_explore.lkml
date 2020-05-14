include: "/users.view"
include: "/events.view"
explore: users {
  join: events {
    relationship: one_to_many
    type: left_outer
    sql_on: ${users.id}=${events.user_id} ;;
  }
}
