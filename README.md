# SERVER TUTORIAL
Tutorial project of a java web server with test endpoints, deployed in a docker container on an amazon ec2 container, provisioned with terraform and configured using ansible.  
The project is (and will be) a work in progress.
## Dependencies
- aws is used to host the resources
```
aws --version
aws-cli/2.9.19 Python/3.11.2 Linux/6.1.0-37-amd64 source/x86_64.debian.12 prompt/off
```
- terraform is used to provide the infrastructure
```
terraform --version
Terraform v1.12.2
on linux_amd64
```
- ansible is used to configure the resources
```
ansible --version
ansible [core 2.17.13]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/lorenzo/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/lorenzo/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.11.2 (main, Apr 28 2025, 14:11:48) [GCC 12.2.0] (/usr/bin/python3)
  jinja version = 3.1.2
  libyaml = True
```
- the project run in a docker container built from this image: `tomcat:11.0.1-jdk21-temurin-noble`
```
docker --version
Docker version 28.3.3, build 980b856
```
- maven is used to build the java backend
```
mvn --version
Apache Maven 3.8.7
Maven home: /usr/share/maven
Java version: 17.0.15, vendor: Debian, runtime: /usr/lib/jvm/java-17-openjdk-amd64
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "6.1.0-37-amd64", arch: "amd64", family: "unix"

```
## Usage
- add credentials for the aws profile used in `main.tf`
```
cat ~/.aws/credentials 
[terraform-tutorial]
aws_access_key_id = <AWS_ACCESS_KEY_ID>
aws_secret_access_key = <AWS_SECRET_ACCESS_KEY>
```
- init terraform in `./infrastructure/terraform` directory, plan using local state and apply changes on remote resource
```
make terraform
```
- build source code and deploy on remote resource
```
make deploy
```
- test remote endpoint
```
make curl-test
```
