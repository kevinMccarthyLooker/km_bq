connection: "biquery_publicdata_standard_sql"

include: "users.view"
include: "/views/order_items.view"


view: +order_items {
  dimension: created {
    # sql:
    # --${EXTENDED}
    # ------
    # DATE_ADD(
    # ${EXTENDED}
    # interval 1 day
    # )
    # ;;
  }
}


explore: order_items {}
