variable vpc_cidrblock {}

variable user {}

variable region {}

// COUNT VAR BUG
variable num_cgws {
  description = "Must match the number of items in customer_gateways"
}

variable customer_gateways {
  description = "List of CGWs to which VGWS should be created and connected"
  type        = "list"
}
