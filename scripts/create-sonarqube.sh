#!/bin/bash

# The directory here is where the .yaml files are, not this script location

directory='/home/<<user>>/k8s-sonarqube'

names='sonar-pv-postgres.yaml sonar-pvc-postgres.yaml sonar-postgres-deployment.yaml sonarqube-deployment.yaml sonarqube-service.yaml sonar-postgres-service.yaml'
for name in $names
do
        kubectl create -f $directory/$name
done
echo "SonarQube on Postgres SQL under Kubernetes is coming up..."
