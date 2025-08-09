deploy:
	mvn clean install
	docker build -t spring-example .
	docker run -t -p 8080:8080 spring-example

deploy-sudo:
	mvn clean install
	sudo docker build -t spring-example .
	sudo docker run -t -p 8080:8080 spring-example
