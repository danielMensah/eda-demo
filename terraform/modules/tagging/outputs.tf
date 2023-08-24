# Merge input tags with default tags.
output "tags" {
  value = merge(
    tomap({
      "Environment"  = null_resource.tagging.triggers.environment,
      "PartOf"       = null_resource.tagging.triggers.part_of,
      "Name"         = null_resource.tagging.triggers.name,
      "Component"    = null_resource.tagging.triggers.component,
      "Orchestrator" = null_resource.tagging.triggers.orchestrator,
      "SourceRepo"   = null_resource.tagging.triggers.repository,
    }),
    var.tags
  )

  description = "Default tags for all resources."
}
