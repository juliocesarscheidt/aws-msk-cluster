#!make

PLAN_FILE="tfplan"

STAGE?=development

AWS_DEFAULT_REGION?=sa-east-1
AWS_BACKEND_BUCKET_NAME?=kafka-cluster-backend-g5kn8m11jvr9

KAFKA_CLUSTER_NAME?=kafka-cluster
KAFKA_LOGS_BUCKET_NAME?=kafka-cluster-g5kn8m11jvr9

fmt:
	terraform fmt -write=true -recursive

validate:
	terraform validate

create-bucket-backend:
	-@echo "Creating the bucket"
	aws s3 ls s3://$(AWS_BACKEND_BUCKET_NAME) --region $(AWS_DEFAULT_REGION) 2>/dev/null || \
		aws s3 mb s3://$(AWS_BACKEND_BUCKET_NAME) --region $(AWS_DEFAULT_REGION)

init: create-bucket-backend
	-@echo "Init"
	terraform init -upgrade=true \
		-backend-config="bucket=$(AWS_BACKEND_BUCKET_NAME)" \
		-backend-config="key=tfstate" \
		-backend-config="workspace_key_prefix=terraform/$(KAFKA_CLUSTER_NAME)" \
		-backend-config="region=$(AWS_DEFAULT_REGION)" \
		-backend-config="access_key=$(AWS_ACCESS_KEY_ID)" \
		-backend-config="secret_key=$(AWS_SECRET_ACCESS_KEY)" \
		-backend-config="encrypt=true"
	make validate
	-@terraform workspace new development 2> /dev/null
	-@terraform workspace new staging 2> /dev/null
	-@terraform workspace new production 2> /dev/null
	terraform workspace select $(STAGE)
	make plan

create-bucket-kafka-logs:
	-@echo "Creating the bucket"
	aws s3 ls s3://"$(KAFKA_LOGS_BUCKET_NAME)" --region $(AWS_DEFAULT_REGION) || \
		aws s3 mb s3://"$(KAFKA_LOGS_BUCKET_NAME)" --region $(AWS_DEFAULT_REGION)

plan: create-bucket-kafka-logs
	-@echo "Plan"
	terraform plan \
		-out=$(PLAN_FILE) \
		-var-file=$(STAGE).tfvars \
		-var stage="$(STAGE)" \
		-var aws_region="$(AWS_DEFAULT_REGION)" \
		-var kafka_logs_bucket_name="$(KAFKA_LOGS_BUCKET_NAME)" \
		-var kafka_cluster_name="$(KAFKA_CLUSTER_NAME)-$(STAGE)" \
		-input=false

apply: plan
	-@echo "Apply"
	terraform apply $(PLAN_FILE)
	terraform output -json

destroy: plan
	-@echo "Destroy"
	terraform destroy \
		-var-file=$(STAGE).tfvars \
		-auto-approve
