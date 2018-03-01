#!/bin/bash

directory='/root/k8s-sonarqube'

names='sonar-pv-postgres.yaml sonar-pvc-postgres.yaml sonar-postgres-deployment.yaml sonarqube-deployment.yaml sonarqube-service.yaml sonar-postgres-service.yaml sonarqubelb-service.yaml'
for name in $names
do
        kubectl create -f $directory/$name
done
echo "SonarQube on Postgres SQL under Kubernetes is coming up..."
