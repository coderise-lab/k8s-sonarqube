# Configure Local Environment - Sonar-Scanner with Golang

## Purpose
This document will walk through how to install the needed apps on your local/dev environment to scan GoLang code with Sonar Scanner.

## Prerequisites
You will need to have the following in order to complete this configuration:
1. A SonarQube Server Instance up and running with the required configuration. (You can use my other guild here: sonar-golang.md that is a part of this repo.)
2. GoLang code to scan.
3. Dev/Local machine with access to the internet to download files (or copy from remote location inside network)
4. Dev/local machine with GoLang installed

##### Note:
> This repo and documentation within works primarily with Kubernetes for the Sonar environment setup. You do NOT NEED to set it up this way in order for this part to work. This will work with any sonar environment that is configured properly (see golang-sonar.md for required plugins and configuration needed on the server).

> This document will not cover fine tuning of Rules, Linters or anything else. This is just to get you up and running to check code with GoLang.
