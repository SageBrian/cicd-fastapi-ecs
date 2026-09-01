output "alb_dns_name" {
  description = "Public URL of the load balancer"
  value       = aws_lb.app.dns_name
}

output "ecr_repository_url" {
  description = "ECR repo to push images to"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "codedeploy_app_name" {
  value = aws_codedeploy_app.app.name
}

output "codedeploy_deployment_group" {
  value = aws_codedeploy_deployment_group.app.deployment_group_name
}

output "github_actions_role_arn" {
  description = "Put this in your GitHub repo as AWS_ROLE_ARN secret/variable"
  value       = aws_iam_role.github_actions.arn
}

output "task_execution_role_arn" {
  value = aws_iam_role.ecs_execution.arn
}

output "task_role_arn" {
  value = aws_iam_role.ecs_task.arn
}
