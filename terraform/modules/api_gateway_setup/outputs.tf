output "api_gateway_url" {
  value = "${aws_api_gateway_stage.flask_stage.invoke_url}/${var.path}"
}
