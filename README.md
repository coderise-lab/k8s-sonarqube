# SonarQube (server) Installation (Kubernetes) - for GoLang scanning
###### Documentation By: Dennis Christilaw (https://github.com/Talderon)
###### Original .yaml forked from: https://github.com/coderise-lab/k8s-sonarqube

## Purpose
This document is meant to help anyone that wants to perform code quality checks for GoLang with SonarQube running in Kubernetes. The server will have a Postgres SQL backend to store scan data. This will live in a persistant volume that this process creates.

This document does NOT go into setting up a Kubernetes Environment. The assumption is that you have one running and ready for deployment.
## Prerequisites
In order to complete this process, you will need to have the following:

1. A Kubernetes Cluster that you have access to deploy to. This can be a local cluster or cloud based (I have tested this on AWS, Azure, Google Cloud and OpenStack)
2. A Dev Machine to run the commands from (this machines must have access to the Kubernetes Cluster and access to the internet
3. Kubectl installed and working (connecting to your KubeCluster) >> https://kubernetes.io/docs/tasks/tools/install-kubectl/

Tested OS's for this process:

1. Ubuntu (14.0.4 and 16.0.4) (When installing kubectl on Ubuntu, I suggest you use the Snap install method: sudo snap install kubectl --classic)
2. CentOS 7
3. Red Hat 7
4. Ubuntu Bash for Windows 10
5. MAC OS X High Sierra (10.13) (Highly suggested you install Homebrew (https://brew.sh/) and install Kubernetes using that: brew install kubectl)

I am sure other OS's will run this without issue, however, those are the only OS's I have personally tested on.

> I have not tested anything natively on Windows OS's as they are more prone to issues than Linux based systems. Note that these instructions are OS Platform Agnostic (for the most part) as long as it is Linux Based. I have no plans (at this time) to test in a native Windows environment due to my current workload. If there is enough demand, I might be able to get it in sooner rather than later.

## Preparing for deployment of SonarQube with a Postgres Database
The following steps will be performed on either your local environment or your Development Machine.

##### Clone the repo with the manifest files
You can clone my repo as it includes a few new things from the original that you may find helpful.
```
git clone https://github.com/Talderon/k8s-sonarqube.git
```
This repo includes a loadbalancer file as well as pre-written scripts to bring up or tear down this deployment (currently no in use, there are issues with it, but probably Kubernetes Cluster Config).

##### Create Postgres Password
There is a .password file included in this repo with a password.
> If you are not running this on a local/dev machine, please change it using a strong password generator.
kubectl create secret generic postgres-pwd --from-file=./password

##### Perform the deployment
Run Manifests (Script Below)

>Edit the directory variable to match where you put the .yaml files
>The files must be run in the order they are presented in the $name variable

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

http://10.145.85.140:31862

Verify that you can log into SonarQube.

> The default login is admin/admin.

##### Download the latest version of the GoLang plugin

> Be sure to get the latest STABLE build and not an RC Build

```
wget https://github.com/uartois/sonar-golang/releases/download/v1.2.10/sonar-golang-plugin-1.2.10.jar
```

Put the jar file in $SONAR_PATH/extensions/plugins

##### Get the information needed to copy the plugin to the Sonar Pod
To get your deployment names, use:
```
kubectl get po
```
Output will be similar to below. You are looking for the SonarQube deployment, not the postgres.
```
NAME                              READY     STATUS    RESTARTS   AGE
sonar-postgres-5cb7db96cb-9w68k   1/1       Running   0          1d
sonarqube-664b4fd48-g6nvb         1/1       Running   0          1d
```

To get your Namespace/Pod names, use the following command:
```
kubectl get pods -o wide --all-namespaces
```
The top several entries will looking like this:

```
NAMESPACE     NAME                                        READY     STATUS    RESTARTS   AGE       IP              NODE
default       sonar-postgres-5cb7db96cb-9w68k             1/1       Running   0          21h       10.233.66.9     local-node-1
default       sonarqube-664b4fd48-g6nvb                   1/1       Running   0          21h       10.233.64.6     local-node-0
kube-system   dnsmasq-758774d558-m46t5                    1/1       Running   0          1d        10.233.66.2     local-node-1
kube-system   dnsmasq-758774d558-nxdcp                    1/1       Running   0          1d        10.233.64.2     local-node-0
kube-system   dnsmasq-autoscaler-856b5c899b-42t4c         1/1       Running   0          1d        10.233.66.3     local-node-1
```
You are looking for the entry that is the same as the pod name you found earlier.

The Namespace/Pod in this example is: default/sonarqube-664b4fd48-g6nvb

> If you log into the pod directly the folder name will be similar to below:
```
/var/lib/docker/devicemapper/mnt/43a83d175fc461f945ba18760dcc1c4969d14701889cf52874960ccff241c030/rootfs/opt/sonarqube/extensions/plugins
```

You can copy the file from your local machine to the Kubernetes Pod using the following instructions:

Syntax:
```
kubectl cp /tmp/foo <some-namespace>/<some-pod>:/tmp/bar
```
Example
```
kubecpl cp /home/user/sonar-golang-plugin-1.2.10.jar default/sonarqube-664b4fd48-g6nvb:/opt/sonarqube/extensions/plugins
```
##### Install/Enable plugins.
The following Plugins are requires as well as this GoLang, you can install these from the GUI:

Administration > Marketplace

> Checkstyle (this should be automatically installed with the GoLang Plugin)

> Golang (this is the one we just installed)

> SonarJava (you will need to hit the install button on this one)


###### Re-Start sonarqube server
Easiest way is to use the GUI to restart

> Administration > System > Restart Server

Once completed, log back in and verify that the 3 plugins are installed without errors.

> Administration > Marketplace

To set up your local environment, please consult the GoLang Sonar-Scanner local configuration Markdown File in this repo.
