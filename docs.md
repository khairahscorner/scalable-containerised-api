Infrastructure Provisioning
- 

to setup load balancer:
- need to create the LB
- set a target group 
    - target groups decouple the LB from the actual targets (i.e its target groups that actually forwards traffic to the services), so the LB doesn't need to know what happens inside those resources or if things change; it uses target group to keep a constant and just focus on sending the traffic
    - target groups do the tracking of the targets, monitors their health, etc
- set a listener for the LB to listen 
    - the middleman between the load balancer and the target group
    - listens for requests to the LB and determines how the traffic should route


- Build image: docker build -t streamlit_app . 

Deploy to ECS
- setup env: `sh ecr_setup.sh`
- configure ECS and deploy: `sh ecs_task_setup.sh`

GitHub actions
- running `terraform apply` with auto-approve is not recommended;
- best practice: setup GitHub environments to require approvals and use the environments


All variables needed in .env

- OPENWEATHER_API_KEY
- AWS_REGION
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_ACCOUNT_ID
