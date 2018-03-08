#!/bin/bash

services='sonar sonarqube sonar-postgres'
deployments='sonarqube sonar-postgres'
pvc='claim-postgres'
pv='pv0001'
  kubectl delete svc $services
  kubectl delete deployments $deployments
  kubectl delete pvc $pvc
  kubectl delete pv $pv
echo "SonarQube on Postgres SQL under Kubernetes is being removed..."
