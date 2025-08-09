HOST = $(shell cat ansible/hosts)

tf-plan:
	cd terraform && terraform plan

tf-apply:
	cd terraform && terraform apply --auto-approve

tf-destroy:
	cd terraform && terraform destroy

deploy:
	cd ansible && ansible-playbook main.yml --private-key ~/.ssh/terraform_tutorial -i hosts

ssh:
	ssh admin@$(HOST) -i ~/.ssh/terraform_tutorial

host:
	echo $(HOST)