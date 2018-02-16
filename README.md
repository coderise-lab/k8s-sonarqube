# DRAFT - This document is not complete, yet

# k8s-sonarqube
SonarQube for Kubernetes.

You will need a base system in order to run the commands and perform maintenance on the Kubernetes Cluster. You can use a local OS installation (MAC OS Terminal, Ubuntu Bash on Windows, Linux, Virtual Machine).

The examples in this document assume you are using a Red Hat distro (CentOS, Amazon Linux and so on), if you are using a different distribution, please correct the commands for the package installers to the one supported by your OS (yum for Red Hat based or apt-get for Ubuntu based and so forth).

All of these commands will be run from the local machine. This machine can also be an instance on AWS.

The following steps, you will install KubeCTL and Kops to manage the Kubernetes cluster and all modes/pods/minions inside them.

Additional steps (install wget, curl etc.) are here in case you are using a Minimal Install of CentOS (or another distro). You might have these installed already.

# Prerequisites

##### For AWS Deployments (which is what this document relies on), you will need to configure a VALID Domain Name in Route 53

##### Install KubeCTL

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

##### Install wget (Optional in case you are using a bare minimum Linux Install)
sudo yum -y install wget

##### Install KOPS
wget https://github.com/kubernetes/kops/releases/download/1.8.0/kops-linux-amd64
chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops

##### Install CURL (Optional in case you are using a bare minimum Linux Install (CentOS/AWS Linux/Red Hat/Fedora))
sudo yum -y install curl

##### Install NTP and Sync Clock and set up polling to NTP Server
###### This will take care of errors like: An error occurred (RequestTimeTooSkewed) when calling the ########## operation

sudo yum install -y ntp ntpdate ntp-doc
sudo ntpdate pool.ntp.org

##### Install PIP

curl -O https://bootstrap.pypa.io/get-pip.py
python get-pip.py --user
export PATH=~/.local/bin:$PATH
source ~/.bash_profile
pip --version

##### Install AWS CLi

pip install awscli --upgrade --user
aws --version

##### Install dig

sudo yum -y install bind-utils
dig --version
dig NS example.com
##### Configure AWS Cli (region being used is us-west-2)

aws configure

# Create Kubernetes Cluster and Deploy

## Prerequisites

##### Create S3 Buckets
aws s3 mb s3://clusters.example.com

##### Export the Cluster State to the new S3 Buckets
export KOPS_STATE_STORE=s3://clusters.example.com

##### Create SSH Keypair for the cluster (You can use an existing one if you like, just know the path to it)
ssh-keygen -t rsa

## Creating the Cluster
##### Create Cluster (Preview mode, no changes to AWS will be made at this time)
kops create cluster --name uswest2a-clusters.example.com --ssh-public-key=~/.ssh/kube1.pub --state=s3://clusters.example.com --zones=us-west-2a

##### Apply Cluster to AWS (This step WILL cause resources that cost money to create)
kops update cluster --name uswest2a-clusters.example.com --ssh-public-key=~/.ssh/kube1.pub --state=s3://clusters.example.com --yes

##### Create Secret For Postgres Sql - This command may fail until the instances are up and passed their "Status Checks"
kubectl create secret generic postgres-pwd --from-literal=password=CodeRise_Pass

##### Output
> secret "postgres-pwd" created

## Perform the deployment
##### Run Manifests (Script Below)
You can get the .yaml files here: git clone https://github.com/Talderon/k8s-sonarqube.git
```
Edit the directory name to match where you put the .yaml files
```
_The files must be **run in the order they are presented** in the $name variable_


 ```bash
 #!/bin/bash
 directory='/home/user/k8s-sonarqube'
 names='sonar-pv-postgres.yaml sonar-pvc-postgres.yaml sonar-postgres-deployment.yaml sonarqube-deployment.yaml sonarqube-service.yaml sonar-postgres-service.yaml'
 for name in $names
 do
         kubectl create -f $directory/$name
 done
 echo "SonarQube on Postgres SQL under Kubernetes is coming up..."
```

##### Output from the script above (this is the correct output)
```
persistentvolume "pv0001" created
persistentvolumeclaim "claim-postgres" created
deployment "sonar-postgres" created
deployment "sonarqube" created
service "sonar" created
service "sonar-postgres" created
SonarQube on Postgres SQL under Kubernetes is coming up...
```

##### Expose service to public
> Expose SonarQube deployment - **Not sure this is needed**

kubectl expose deployment sonarqube --type=NodePort

##### Check PODS
kubectl get po -o wide

##### Check Sonar Service
kubectl get svc

##### Sample Output
[user@kube01 ~]$ kubectl get svc

| NAME | TYPE | CLUSTER-IP | EXTERNAL-IP | PORT(S) | AGE
| --- | --- | --- | --- | --- | --- |
|kubernetes | ClusterIP | 100.64.0.1 | none | 443/TCP | 5m
|sonar | NodePort | 100.65.73.92  |   none   |     80:32683/TCP |    1m
|sonar-postgres |  ClusterIP  | 100.71.28.143  |  none     |   5432/TCP    |     1m
|sonarqube    |    NodePort  |  100.66.183.189 | none     |  9000:32701/TCP  | 11s

##### This will expose the Sonarqube deployment with a public IP Address
kubectl expose deployment sonarqube --name sonarqubelb --port 80 --target-port=9000  --type=LoadBalancer

##### Get the current services
kubectl get svc

##### Sample Output (SonarQube port in RED)
[user@kube01 ~]$ kubectl get svc

|NAME     |        TYPE   |        CLUSTER-IP |     EXTERNAL-IP  |      PORT(S)    |    AGE
| --- | --- | --- | --- | --- | --- |
|kubernetes   |    ClusterIP   |   100.64.0.1   |   none |             443/TCP    |    13m
|sonar     |       NodePort     |  100.71.53.162 |  none      |       80:30674/TCP  | 4m
|sonar-postgres |  ClusterIP   |   100.64.82.137 |  none      |     5432/TCP  |     4m
|sonarqubelb |     LoadBalancer  | 100.65.196.55  | aa5a555a31277...  | 80:32479/TCP |  1m

##### Get a better view of the SonarQube service detail in order to get LoadBalancer Information
kubectl describe svc sonarqubelb

##### Sample Output 
[user@kube01 ~]$ kubectl describe svc sonarqubelb

```
Name:                     sonarqubelb
Namespace:                default
Labels:                   name=sonarqube
Annotations:              none
Selector:                 name=sonarqube
Type:                     LoadBalancer
IP:                       100.65.196.55
LoadBalancer Ingress:     aa5a555a31277-lots_of_digits.us-west-2.elb.amazonaws.com
Port:                     unset  80/TCP
TargetPort:               31815/TCP
NodePort:                 unset  32479/TCP
Endpoints:
Session Affinity:         None 
External Traffic Policy:  Cluster
Events:
  Normal  EnsuringLoadBalancer  4m    service-controller  Ensuring load balancer
  Normal  EnsuredLoadBalancer   4m    service-controller  Ensured load balancer
```

##### Default username/password is: admin/admin

##### Optional, create a CNAME for your domain to the SonarQube LoadBalancer DNS Name (only do this if the plan is to keep this up)

##### Deleting the Cluster
> **This command will remove the cluster and cluster states from the S3 Bucket and Terminate all AWS Instances that have been stood up for this cluster**

kops delete cluster --name uswest2a-clusters.example.com --state=s3://clusters.example.com --yes

# Appendix

##### Remove a service
> Service Names can be aquired by running the 'kubectl get svc' command

kubectl delete service service-name
