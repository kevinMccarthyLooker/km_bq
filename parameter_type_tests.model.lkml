connection: "snowlooker"

include: "/users.view"

view: +users {
  parameter: test {
    type: string
  }
  dimension: use_parameter {sql:{%assign final = test._parameter_value |split:"'"%}{{final}};;}
}
explore: users {}
