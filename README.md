# k8s-sonarqube
SonarQube for Kubernetes with PostgresSQL.

You will need a base system in order to run the commands and perform maintenance on the Kubernetes Cluster. You can use a local OS installation (MAC OS Terminal, Ubuntu Bash on Windows, Linux, Virtual Machine).

The examples in this document assume you are using a linux distro (these instructions should run without edits on Red Hat/Debian based or other flavors), if you are using a different distribution, please correct the commands for the package installers to the one supported by your Linux OS.

All of these commands will be run from the local machine. This machine can also be an instance on a cloud providor or in OPenstack if you are running a localized environment.

The following steps, you will install KubeCTL to manage the Kubernetes cluster and all modes/pods/minions inside them.

##### Install KubeCTL

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl

# Create Kubernetes Cluster and Deploy

##### Create SSH Keypair for the cluster (You can use an existing one if you like, just know the path to it)
ssh-keygen -t rsa

# Creating the Cluster
### Create Postgres Password
There is a .password file included in this repo with a password.

If you are not running this on a local/dev machine, you can use the password provided. If you are running anywhere near a public space, please change it using a strong password generator.
kubectl create secret generic postgres-pwd --from-file=./password

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
 names='sonar-pv-postgres.yaml sonar-pvc-postgres.yaml sonar-postgres-deployment.yaml sonarqube-deployment.yaml sonarqube-service.yaml sonar-postgres-service.yaml sonar-postgres-service.yaml'
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

##### Check PODS
kubectl get po -o wide

##### Check Sonar Service
kubectl get svc

##### Get a better view of the SonarQube service detail in order to get LoadBalancer Information
kubectl describe svc sonarqubelb

##### Sample Output
[user@kube01 ~]$ kubectl describe svc sonarqubelb

```
Coming soon...
```

##### Default username/password is: admin/admin

# Appendix

##### Remove a service/deployment/other
kubectl delete service service-name

kubectl delete deployment service-name

##### You can obtain all of the deployments/svc/replicationcontrollers and so on with the following command:
kubectl get all

##### Sample output
```
NAME                    DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deploy/sonar-postgres   1         1         1            1           18h
deploy/sonarqube        1         1         1            1           18h

NAME                           DESIRED   CURRENT   READY     AGE
rs/sonar-postgres-5cb7db96cb   1         1         1         18h
rs/sonarqube-664b4fd48         1         1         1         18h

NAME                    DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deploy/sonar-postgres   1         1         1            1           18h
deploy/sonarqube        1         1         1            1           18h

NAME                           DESIRED   CURRENT   READY     AGE
rs/sonar-postgres-5cb7db96cb   1         1         1         18h
rs/sonarqube-664b4fd48         1         1         1         18h

NAME                                 READY     STATUS    RESTARTS   AGE
po/sonar-postgres-5cb7db96cb-d7wf5   1/1       Running   0          18h
po/sonarqube-664b4fd48-f62q2         1/1       Running   0          18h

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
svc/kubernetes       ClusterIP   10.233.0.1      <none>        443/TCP        19h
svc/sonar            NodePort    10.233.45.191   <none>        80:31337/TCP   18h
svc/sonar-postgres   ClusterIP   10.233.54.237   <none>        5432/TCP       18h
svc/sonarqube        ClusterIP   10.233.54.173   <none>        9000/TCP       17h
```
