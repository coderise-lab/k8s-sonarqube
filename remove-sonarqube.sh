#!/bin/bash

services='sonar sonarqube sonar-postgres'
deployments='sonarqube sonar-postgres'
  kubectl delete svc $services
  kubectl delete deployments $deployments
echo "SonarQube on Postgres SQL under Kubernetes is being removed..."
