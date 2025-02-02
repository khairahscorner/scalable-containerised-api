## Infrastructure Provisioning

### Issues encountered
- mostly syntax related errors,
- dividing terraform provisioning to be able to run docker job in between (used `-target` option on `terraform apply` to provision ecr setup needed for docker run)
- managing tfstate with terraform backend block (type s3): the lack of state management was causing terraform to recreate alll resources on every run, like a fresh start. [Docs](https://developer.hashicorp.com/terraform/language/terraform#terraform-backend)

To setup load balancer:
- need to create the LB
- set a target group 
    - target groups decouple the LB from the actual targets (i.e its target groups that actually forwards traffic to the services), so the LB doesn't need to know what happens inside those resources or if things change; it uses target group to keep a constant and just focus on sending the traffic
    - target groups do the tracking of the targets, monitors their health, etc
- set a listener for the LB to listen 
    - the middleman between the load balancer and the target group
    - listens for requests to the LB and determines how the traffic should route

- Revise API gateway setup (use console/aws-cli)

GitHub actions
- best practice: setup GitHub environments to require approvals for terraform runs before using auto-approve (limited it to first job only)


All secrets/variables needed in repo for GHA

- OPENWEATHER_API_KEY
- AWS_REGION
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_ACCOUNT_ID
- DEV_ENVIRONMENT

TODO: Enhancements with dynamoDB and elasticache