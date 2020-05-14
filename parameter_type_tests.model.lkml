connection: "snowlooker"

include: "/users.view"

view: +users {

  parameter: test {
    type: string
  }
  measure: use_parameter {sql:{%assign final = test._parameter_value |split:"'"%}{{final}};;type:number}
}
explore: users {
  access_filter: {
    field: users.id
    user_attribute: id
  }
}
