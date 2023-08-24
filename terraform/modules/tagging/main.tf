resource "null_resource" "tagging" {
  triggers = {
    environment  = lower(format("%v", var.environment))
    part_of      = lower(format("%v", var.part_of))
    name         = lower(format("%v", var.name))
    component    = lower(format("%v", var.component))
    orchestrator = lower(format("%v", var.orchestrator))
    repository   = lower(format("%v", var.repository))
  }
}
