# Setting variables
# Folder fixed variables (could not be changed)
export CLOUDFORMATION_FOLDER=infra-cf
export TERRRAFORM_FOLDER=infra-tf
export LAMBDA_CODE_FOLDER=lambda_code
export SCRIPTS_FOLDER=scripts
export TESTING_FOLDER=testing
# Rest variables (the following can be changed)
export STACK_NAME=IdleResouceCheckerStack
export AWS_REGION=eu-west-1

all-cf: build deploy-cf test-cf-listing test-generate test-apigateway-inittest test-generate test-apigateway-curl clean-cf
	# runs sequentially all the workflow for AWS using CloudFormation yaml definitions and aws cli uploading files

all-tf: build deploy-tf test-tf-listing test-generate test-apigateway-inittest test-generate test-apigateway-curl clean-tf
	# runs sequentially all the workflow for AWS using terraform custom modules

build:
	# builds lambda bundles (.zip files) to be uploaded to aws
	sh $(SCRIPTS_FOLDER)/build-lambda-package.sh

deploy-cf:
	# creates of all the needed resources on AWS account using CloudFormation
	sh $(SCRIPTS_FOLDER)/deploy_cf_from_local.sh
	sh $(SCRIPTS_FOLDER)/deploy_cf_lambda_code_awscli.sh

deploy-tf:
	# creates of all the needed resources on AWS account using Terraform
	sh $(SCRIPTS_FOLDER)/deploy_tf_from_local.sh

test-cf-listing:
	# lists the resources generated for cloudformation stack on aws account using "aws cli" commands
	sh $(TESTING_FOLDER)/listing_cf_resources.sh

test-tf-listing:
	# lists the resources generated for cloudformation stack on aws account using "aws cli" commands
	sh $(TESTING_FOLDER)/listing_tf_resources.sh

test-generate:
	# generates different dummy idle resources (ENIs, LoadBalancer and EIPs) on AWS account for testing propouses
	sh $(TESTING_FOLDER)/generate_idle_resources.sh

test-apigateway-curl:
	# launching apigateway endpoints for ENIs (<API_URL>/enis-scan), LoadBalancer (<API_URL>/elbs-scan) and EIPs (<API_URL>/eips-scan) scans and shows the results
	sh $(TESTING_FOLDER)/run-apigateway-tests-curl.sh

test-apigateway-inittest:
	# launching apigateway endpoints on AWS using python3 inittest
	sh $(TESTING_FOLDER)/run-apigateway-tests-inittest.sh

clean-cf:
	# deletes the created cloudformation stack
	sh $(SCRIPTS_FOLDER)/wrap-up-cf.sh

clean-tf:
	# deletes the created terraform resources
	sh $(SCRIPTS_FOLDER)/wrap-up-tf.sh
