connection: "biquery_publicdata_standard_sql"

include: "/*.view.lkml"                # include all views in the views/ folder in this project


view: +events {
  measure: test_liquid {
    sql: max(1) ;;
    html:
    1:{{value}}
    2:{{value | url_encode}}
    3:{{value|url_encode}}
    ;;
    link: {
      label: "go there with delmiter"
      url: "dashboards/ \" t"
    }
  }
}
explore: events {}
