# SonarQube with Postgres Database running in Kubernetes for GoLang code scanning
###### Documentation By: Dennis Christilaw (https://github.com/Talderon)

## Purpose
This document explains the scrips that are stored in this dorectory.

## Creation and Removal
###### create-sonarqube.sh
This script just automates the SonarQube Server creation with PostgresSQL Database.

The following will be created (in this order):
1. sonar-pv-postgres.yaml
    1. This creates the persistant volume in the Kubernetes Cluster for Database Storage
2. sonar-pvc-postgres.yaml
    1. This claims the persistant volume that was created
3. sonar-postgres-deployment.yaml
    1. This is the actual deployment of the Postgres Database
4. sonarqube-deployment.yaml
    1. SonarQube Server Deployment
5. sonarqube-service.yaml
    1. SonarQube Cluster Service
6. sonar-postgres-service.yaml
    1. Postgres Database Service

##### remove-sonarqube.sh

This script remove all of the components above from the Kubernetes Cluster.

## Automation

The scripts for Automation are to streamline the process with as little infrastructure/bash scripting that can be accomplished for this configuration. There are user input promps for certain bits of information, otherwise, fully automatged.

##### sonar-server-setup.sh

This is the core scrip that was written primarilu for Ubuntu installation. This is the core script other variants will be built from.

> It is not recommended to use this script unless you plan to edit for your needs.

##### ubuntu-sonarqube-setup.sh

This is the first in a series of targetted Operating System scripts. Please check inside the script for any notes.
