# SERVER TUTORIAL
Tutorial project of a java web server with test endpoints, deployed in a docker container on an amazon ec2 resource, provisioned with terraform and configured using ansible.
The project is (and will be) a work in progress.
## Dependencies
- aws `2.9.19`
- terraform `1.12.2`
- ansible `2.17.13`
- docker `28.3.3`
- maven `3.8.7`
## Setup
- create aws user with access key and add profile to local configuration
```
$ aws configure --profile server-tutorial
```
- generate ssh key pair (default name: `server-tutorial`)
```
$ ssh-keygen -t rsa
```
## Usage
- init terraform in `./infrastructure/terraform` directory, plan using local state and apply changes on remote resource
```
$ make terraform
```
- build source code and deploy on remote resource
```
$ make deploy
```
- test remote endpoint
```
$ make curl-test
```
