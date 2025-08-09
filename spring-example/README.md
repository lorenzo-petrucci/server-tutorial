# spring-example
## Startup
Run
```
make deploy
```
## Use
GET example
```
curl http://localhost:8080/spring-example/api
```
POST example
```
curl http://localhost:8080/spring-example/api -d 'example=test'
curl http://localhost:8080/spring-example/api -H 'Content-type: application/json' -d '{"example":"test"}'
```
