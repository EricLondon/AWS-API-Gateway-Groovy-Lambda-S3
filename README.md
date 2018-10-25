### AWS, API Gateway, Groovy, Lambda, S3, Terraform

```
# build groovy lambda
./gradlew clean build

# deploy via terraform
cd terraform
# set variables, secrets.auto.tfvars, etc
./provision.sh apply

# Outputs:
# base_url = https://SOMEHASH.execute-api.us-east-1.amazonaws.com/test

# curl API Gateway endpoint
# Example code to fetch CSV file from S3, convert to JSON, and respond
curl -i -H 'Content-Type: application/json' -XPOST https://SOMEHASH.execute-api.us-east-1.amazonaws.com/test/s3 -d '{"bucket":"SOMEBUCKET","key":"input/sample.csv"}'
HTTP/2 200
content-type: application/json
content-length: 154
date: Wed, 24 Oct 2018 19:54:09 GMT
x-amzn-requestid: SECRET
x-amz-apigw-id: SECRET
x-amzn-trace-id: SECRET
x-cache: Miss from cloudfront
via: 1.1 SECRET.cloudfront.net (CloudFront)
x-amz-cf-id: SECRET

[{"id":"1","first_name":"Eric","last_name":"London"},{"id":"2","first_name":"Foo","last_name":"Bar"},{"id":"3","first_name":"Mr.","last_name":"Biscuits"}]
```
