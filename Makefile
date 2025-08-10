### INFRASTRUCTURE ###

# FIXME: manage multiple IPs in hosts file
HOST = $(shell cat infrastructure/ansible/hosts)

tf-plan:
	cd infrastructure/terraform && terraform init && terraform plan

tf-apply:
	cd infrastructure/terraform && terraform apply --auto-approve

tf-destroy:
	cd infrastructure/terraform && terraform destroy

terraform: tf-plan tf-apply

ansible:
	cd infrastructure/ansible && ansible-playbook main.yml --private-key ~/.ssh/server_tutorial -i hosts

ssh:
	ssh admin@$(HOST) -i ~/.ssh/server_tutorial

echo-hosts:
	echo $(HOST)

### CODE ###

build:
	cd code && mvn clean install

docker-build:
	cd code && docker build -t spring-example-image .

docker-run:
	docker run -d -p 8080:8080 --name spring-example spring-example-image

deploy-local: build docker-build docker-run

deploy: build ansible

docker-exec-bash:
	docker exec -it spring-example bash

catalina-logs:
	docker exec -it spring-example bash -c "cat logs/catalina.*"

catalina-localhost:
	docker exec -it spring-example bash -c "cat logs/localhost.*"

catalina-access:
	docker exec -it spring-example bash -c "cat logs/localhost_access*"

docker-stop:
	docker stop spring-example

clean: docker-stop
	docker rm spring-example

curl-test:
	curl $(HOST)/spring-example/api -vvv