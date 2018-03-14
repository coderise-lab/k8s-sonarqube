# SonarQube with Postgres Database running in Kubernetes for GoLang code scanning
###### Documentation By: Dennis Christilaw (https://github.com/Talderon)

## Purpose
This document is meant to help anyone that wants to perform code quality checks for GoLang with SonarQube running in Kubernetes. The server will have a Postgres SQL backend to store scan data. This will live in a persistant volume that this process creates.

This document series is meant to help anyone that wants to perform code quality checks for GoLang with SonarQube running in Kubernetes. The server will have a Postgres SQL backend to store scan data. This will live in a persistent volume that this process creates.

The reason for this documentation series is that there are no complete set of docs on how to get SonarQube to work with GoLang. GoLang is not officially supported by SonarQube, so the process to get this working can be difficult as there are many moving parts to try and hit this moving target.  Since I was unable to find a complete set of documents that start from the beginning and go to the end in one place, I decided to get this together to help those that are wanting to do this, but find the lack of information daunting.

You will also install the correct plugins for the following functions:

Build Break when scan produced results that do not pass the quality gates (recommended)

SVG Badges to how in repositories that status of the quality checks (Optional)

This document does NOT go into setting up a Kubernetes Environment. The assumption is that you have one running and ready for deployment.

There are plans to have setup process created for MiniKube, AWS, Azure and OpenStack Local Dev Environment (this will work on OpenStack Cloud as well). 

> ETA: Unknown

## Prerequisites
In order to complete this process, you will need to have the following:

1. A Kubernetes Cluster that you have access to deploy to. This can be a local cluster or cloud based (I have tested this on AWS, Azure, Google Cloud and OpenStack Enterprise)
2. A Dev Machine to run the commands from (this machines must have access to the Kubernetes Cluster and access to the internet
3. Kubectl installed and working (connecting to your KubeCluster) >> [Kubernetes Install](https://kubernetes.io/docs/tasks/tools/)install-kubectl/

Tested OS's for this process:

1. Ubuntu (14.0.4 and 16.0.4)
2. CentOS 7
3. Red Hat 7
4. Ubuntu Bash for Windows 10
    1. This is only mentioned here as it is becoming popular, this will NOT work with the Ubuntu Shell for Windows 10
    2. This shell is not a Full Ubuntu shell and cannot run virtualization (VMWare, VirtualBox) or Docker
    3. This was meant only for Development purposes in Linux native in Windows 10
5.	MAC OS X High Sierra (10.13) 
    1. (Highly suggested you install [Homebrew](https://brew.sh/) and install Kubernetes using that: brew install kubectl)


I am sure other OS's will run this without issue, however, those are the only OS's I have personally tested on.

> I have not tested anything natively on Windows OS's as they are more prone to issues than Linux based systems. Note that these instructions are OS Platform Agnostic (for the most part) as long as it is Linux Based. I have no plans (at this time) to test in a native Windows environment due to my current workload. If there is enough demand, I might be able to get it in sooner rather than later.

## Automation (BETA)
The automation script (ubuntu-sonarqube setup.sh) included here is designed to fully automate this process with some user prompted input. This script is in BETA, however, I would encourage anyone to try it and leave some feedback.

I plan to have a similar script for YUM based distributions (I will test on CentOS7 and RHEL 7) in the coming days/weeks. Keep checking back!

#### Install Docker
> Depending on the flavor of the development machine, install [Docker](https://docs.docker.com/engine/installation/).
> (Ubuntu 16.0.4 LTS, you can install with the below commands)

```bash
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common make
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get -y update
sudo apt-get install docker-ce
```

##### The following applies if you install on your local machine

> When you install Docker, Docker may choose an IP address that is the same as the wifi address you are using to connect from your main machine. You need to change the default IP for Docker. It's easiest to do this while being connected with a network cable instead of wifi. Add a new file to the new development machine /etc/docker/daemon.json containing (You can choose your IP CIDER based on your network config):
```json
{
   "bip": "172.30.30.1/24"
}
```
#### Install kubectl
> Install kubectl on your development machine to talk to kube master api instead of the need to login into kubernetes cluster machines.
```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```
Install JQ
```bash
sudo apt-get install -y jq
```

## Preparing for deployment of SonarQube with a Postgres Database
The following steps will be performed on either your local environment or your Development Machine.

##### Clone the repo with the manifest files
You can clone my repo as it includes a few new things from the original that you may find helpful.
```
git clone https://github.com/Talderon/k8s-sonarqube.git
```

##### Create Postgres Password
Using the below method, the user can enter a password securely (no echo), then the password is encrypted and stored in Kubernetes and the variable ($dbpass) is cleared so the password is not stored in an unencrypted state beyond the time it takes to create/encrypt the password.

```bash
echo "Enter your Database Root Password and press enter:"
read -s dbpass
kubectl create secret generic postgres-pwd --from-literal=password=$dbpass
unset dbpass
```

##### Perform the deployment
Run Manifests (Script Below)

> Edit the directory variable to match where you put the .yaml files
> The files must be run in the order they are presented in the $name variable
> The script is oncluded in this repo for your benefit
> in order to run the included scripts, execute the following command in the repo directory:
```bash
chmod +x *.sh
```
Script Contents (creation). The removeal script can be viewed separately.

```bash
#!/bin/bash

directory='/PathToClonedRepo/k8s-sonarqube'

names='sonar-pv-postgres.yaml sonar-pvc-postgres.yaml sonar-postgres-deployment.yaml sonarqube-deployment.yaml sonarqube-service.yaml sonar-postgres-service.yaml'
for name in $names
do
        kubectl create -f $directory/$name
done
echo "SonarQube on Postgres SQL under Kubernetes is coming up..."
```

##### Check Services for the Port Address
```
kubectl get svc
```
> Sample Output
```
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes       ClusterIP   10.233.0.1      <none>        443/TCP        1d
sonar            NodePort    10.233.54.89    <none>        80:31862/TCP   1d
sonar-postgres   ClusterIP   10.233.55.224   <none>        5432/TCP       1d
```

The port address you want to note is the NodePort: 31862

This will be the port you need to access SonarQube
##### Get node external IP
```
kubectl get pods -o wide --all-namespaces
```
>The table output is large, but you want to pull the NGINX IP's from the list for your nodes that will be running the services (not master)

Typically, the installation will be on Node-0, but pull them both as you may need them for later deployments. You will want to make sure you get the entries with -- 'nginx-proxy-local-node-#'

```
kube-system   nginx-proxy-local-node-0   1/1       Running   0    1d     10.145.85.140   local-node-0
kube-system   nginx-proxy-local-node-1   1/1       Running   0    1d     10.145.85.139   local-node-1
```
The URL (using the examples above) that you will use to reach Sonar is:

> http://10.145.85.140:31862/sonar

Verify that you can log into SonarQube.

> The default login is admin/admin.

##### Download the latest version of the GoLang plugin and copy to SonarQube deployment

> Be sure to get the latest STABLE build and not an RC Build

You can copy the file from your local machine to the Kubernetes Pod using the following instructions:

Syntax:
```
kubectl cp /tmp/foo <some-namespace>/<some-pod>:/tmp/bar
```
Example
```
kubecpl cp /home/user/sonar-golang-plugin-1.2.10.jar default/sonarqube-664b4fd48-g6nvb:/opt/sonarqube/extensions/plugins
```

The following snippet can be used to download and copy the plugin to the Container/Pod.
```bash
wget https://github.com/uartois/sonar-golang/releases/download/v1.2.11/sonar-golang-plugin-1.2.11.jar
psonar=( $(kubectl get pods -o wide --all-namespaces | grep sonarqube- ) )
kubectl cp sonar-golang-plugin-1.2.11.jar ${psonar[1]}:/opt/sonarqube/extensions/plugins/
```

Install Build-Breaker Plugin (recommended)

> This plugin will mark the build failed if the project fails its quality gate or uses a forbidden configuration. These checks happen after analysis has been submitted to the server, so it does not prevent a new analysis from showing up in SonarQube.

```bash
wget https://github.com/SonarQubeCommunity/sonar-build-breaker/releases/download/2.2/sonar-build-breaker-plugin-2.2.jar
psonar=( $(kubectl get pods -o wide --all-namespaces | grep sonarqube- ) )
kubectl cp sonar-build-breaker-plugin-2.2.jar ${psonar[1]}:/opt/sonarqube/extensions/plugins/
```

##### Install/Enable plugins.
The following Plugins are requires as well as this GoLang, you can install these from the GUI:

Administration > Marketplace

> Checkstyle (this should be automatically installed with the GoLang Plugin)
> Golang (this is the one we just installed (may not show up until after restart))
> SonarJava (you will need to hit the install button on this one)
> Build Breaker Plugin (this is one that we just installed (may not show up until after restart))
> SVG Badges (you will need to hit the install button on this one (Optional))

###### Re-Start sonarqube server
Easiest way is to use the GUI to restart

> Administration > System > Restart Server

Once completed, log back in and verify that the 3 plugins are installed without errors.

> Administration > Marketplace

To set up your local environment, please consult the GoLang Sonar-Scanner local configuration Markdown File in this repo.

### Continue to Local Environment Setup

[Local Environment Setup](https://github.com/Talderon/k8s-sonarqube/blob/master/golang-sonar-scanner.md)

