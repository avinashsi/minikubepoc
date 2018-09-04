MiniKube Poc
=========

Getting started
---------------
Note: This Poc is done on Windows10 .
Before doing git pull do the following necessary steps first.

Download [Vagrant](https://releases.hashicorp.com/vagrant/2.0.0/vagrant_2.0.0_x86_64.msi).

Download [Vagrant Redhat Box](https://gitlab.com/avinashsi/boxes/blob/master/puppet_rhel7.box)

Download[Oracle virtualbox](https://download.virtualbox.org/virtualbox/5.1.30/VirtualBox-5.1.30-118389-Win.exe)

Install Vagrant and Virtual Box Restart Your system after Installation

Add Vagrant Box in your system Go to download directory where you have downloaded box run following command as below

```
vagrant box add --name minikubepoc puppet_rhel7.box
==> box: Box file was not detected as metadata. Adding it directly...
==> box: Adding box 'minikubepoc' (v0) for provider:
    box: Unpacking necessary files from: file://C:/D_DRIVE/BOX/puppet_rhel7.box
    box:
==> box: Successfully added box 'minikubepoc' (v0) for 'virtualbox'!
```

Check the box list to confirm

```
$ vagrant box list
minikubepoc (virtualbox, 0)

```

Now take clone of this repository at your working directory

```
git clone https://github.com/avinashsi/minikubepoc.git

```
Now browse to the repo folder cd minikubepoc and run following command

```
vagrant up

```
Vagrant will startup a VM in your local workstation with the image you have imported
and start up the MiniKube inside it by using the bootstrap script -bootstrap.sh as mentioned in the Vagrantfile.


```
minikube.vm.provision "shell" , path: "bootstrap.sh"
```

You can refer to the logs on following [link](https://raw.githubusercontent.com/avinashsi/minikubepoc/master/bootstrap_log)

Vagrant also syncs up the local file folder which came up as the clone in your vm

```
 minikube.vm.synced_folder "files", "/home/vagrant/files"
```

Now once the machine is up and running lets fire up the instances

Applocation1 will be hosted as an backend application which will host the
following json file.

```
{
"id": "1",
"message": "Hello world"
}

```

Before firing up the instance first create the Docker Image which will host this json file.
Create a tomcat docker image using the following step. Go the path where you have taken clone.

```
cd minikubepoc\files\Tomcat8_Dockerfile
#####BUIlD Dokcer Image ###############
 docker build -t avinashsi/tomcat:8.053_R2 .

```
This will create a docker image in you local MiniKube workstation with tomcat version 8.053

 Note: Make sure you push it too docker-hub accordingly.

 Now go the following folder and fire up your first application by running the following command .

 ```
 cd files\backend
 kubectl create -f backend_deployment.yaml

 ```
This will fire up the application. The josn file having the content is vm which is the synced inside
container by following configuration defined in file.

```
volumeMounts:
  - mountPath: /home/tomcat/webapps/app/
    name: mypvc
volumes:
- name: mypvc
  hostPath:
    path: /home/vagrant/files/app_data/application1

```

You can check the application status by running the following command.

```
[root@minkube backend]# kubectl get pods
NAME                                  READY     STATUS    RESTARTS   AGE
tomcat1-deployment-66d78b9c6b-j7glw   1/1       Running   0          1h
```

Now our first application is up but as of now it's now exposed to the outer world
i.e. inaccessible from out side Minikube workstation.

Lets expose this application to outside world.

Create a Second Docker Image for Nginx which we will use as fronted to and also
do the job to reverse the message field.

Go to the following directory to create Nginx Docker Image.

```

cd minikubepoc\files\Nginx_Dockerfile
docker build -t avinashsi/nginx:1.14.0-1_R2 .
```
Note: Please make sure you push the image to docker hub.
Befor pushing it to docker hub make sure you tag it properly so that you can push the image.

```
docker push avinashsi/nginx:1.14.0-1_R2
```

Now you are good to go lets configure the Nginx configuration using ConfigMap as shown.

```
cd minikubepoc\files\frontend

cat frontend_application.yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-conf
data:
  nginx.conf: |-
   user  nginx;
    worker_processes  1;

    error_log  /var/log/nginx/error.log warn;
    pid        /var/run/nginx.pid;

    events {
        worker_connections  1024;
    }

    http {
        include       /etc/nginx/mime.types;
        default_type  application/octet-stream;

        sendfile        on;
        keepalive_timeout  65;


        server {
            listen 80;

            root /var/www/app/;
            index reversehellowold.json;

            location / {
                proxy_pass         http://tomcat-one:8080/;
                proxy_redirect     off;
            }
            location /reversehello {
                try_files $uri $uri/ /reversehellowold.json;
            }

        }
    }
```
Add in your other configuration and service to expose this frontend outside the minikube workstation

```
kind: Service
apiVersion: v1
metadata:
  name: frontend
spec:
  type: NodePort
  ports:
  - port: 80
    nodePort: 32080
  selector:
    app: frontend

```
Let's fire up the frontend application which will expose the backend application which we created
before Also reverse the message by executing as shell script which was part of docker image.

```
kubectl create -f frontend_application.yaml

```

Since we have define the configuration to be exposed from outside world in the service we
can see it from there.

```
kind: Service
apiVersion: v1
metadata:
  name: frontend
spec:
  type: NodePort
  ports:
  - port: 80
    nodePort: 32080
  selector:
    app: frontend
````

Grab in the ip from minkube command line as shown below

```
    [root@minkube frontend]# minikube service list
    |-------------|----------------------|------------------------|
    |  NAMESPACE  |         NAME         |          URL           |
    |-------------|----------------------|------------------------|
    | default     | frontend             | http://10.0.2.15:32080 |
    | default     | kubernetes           | No node port           |
    | default     | tomcat-one           | No node port           |
    | kube-system | kube-dns             | No node port           |
    | kube-system | kubernetes-dashboard | http://10.0.2.15:30000 |
    |-------------|----------------------|------------------------|


```
Go to the browser on your system and type in the following url to access the application.

```
http://192.168.111.11:32080/app/helloworld.json
```
![alt text](https://raw.githubusercontent.com/avinashsi/minikubepoc/master/Images/helloworld.png)

Now lets try to access the reverse application which will revert the message in json files
by going to the following url.

```
http://192.168.111.11:32080/reversehello
```
![alt text](https://raw.githubusercontent.com/avinashsi/minikubepoc/master/Images/reversehellowold.png)

This url is created by following configuration defined in ConfigMap

```
location /reversehello {
    try_files $uri $uri/ /reversehellowold.json;

```

The fronted application curl the url from the backend application and ran it as post start script
as defined in the yaml files

```
postStart:
        exec:
          command: ["/bin/sh", "-c", "/opt/data_parse.sh"]

```

Multiple instances of Application
-----

As of now in the above example we have shown we are running only one pod for this application as shown below.

```
[root@minkube backend]#  kubectl get deployments
NAME                 DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
tomcat1-deployment   1         1         1            1           2h
[root@minkube backend]#
```
```
###Replicas in kcompose  file as of now
replicas: 1

```
We can scale the pods either by updating the following variable in file or by following command as shown below.
```
replicas: 4

or

kubectl scale deployments tomcat1-deployment --replicas=4

```
Check the o/p it will return the same.

```
[root@minkube backend]#  kubectl get deployments
NAME                 DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
tomcat1-deployment   4         4         4            0           4s
[root@minkube backend]#

```

The change was applied, and we have 4 instances of the application available. Next, let’s check if the number of Pods changed:

```
[root@minkube backend]# kubectl get pods -o wide
NAME                                  READY     STATUS    RESTARTS   AGE       IP           NODE
frontend                              1/1       Running   0          2h        172.17.0.4   minikube
tomcat1-deployment-66d78b9c6b-8kqzw   1/1       Running   0          3m        172.17.0.6   minikube
tomcat1-deployment-66d78b9c6b-hxmnp   1/1       Running   0          3m        172.17.0.9   minikube
tomcat1-deployment-66d78b9c6b-jnxwd   1/1       Running   0          3m        172.17.0.8   minikube
tomcat1-deployment-66d78b9c6b-p2wfs   1/1       Running   0          3m        172.17.0.7   minikube


```
There are 4 Pods now, with different IP addresses. The change was registered in the Deployment events log.


Rolling Updates for your Application
----
Users expect applications to be available all the time and developers are expected to deploy new versions of them
several times a day. In Kubernetes this is done with rolling updates. Rolling updates allow Deployments' update to
take place with zero downtime by incrementally updating Pods instances with new ones.

In the previous example we scaled our application to run multiple instances. This is a requirement for performing updates
without affecting application availability. By default, the maximum number of Pods that can be unavailable during the update
and the maximum number of new Pods that can be created, is one. Both options can be configured to either numbers or percentages
(of Pods). In Kubernetes, updates are versioned and any Deployment update can be reverted to previous (stable) version.

Rolling updates allow the following actions:

1.Promote an application from one environment to another (via container image updates)
2.Rollback to previous versions
3.Continuous Integration and Continuous Delivery of applications with zero downtime


In our example we have an docker image which has an updated version of tomcat9.0.11 and as of now we the current version of
deployment is using tomcat8.053.

Before rolling up the update lets take down the note of the docker image used as of now by running the following command.

```
[root@minkube backend]# kubectl describe deployments tomcat1-deployment
Name:                   tomcat1-deployment
Namespace:              default
CreationTimestamp:      Tue, 04 Sep 2018 16:57:50 -0400
Labels:                 app=tomcat1-helloworld
Annotations:            deployment.kubernetes.io/revision=1
Selector:               app=tomcat1-helloworld
Replicas:               4 desired | 4 updated | 4 total | 4 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:  app=tomcat1-helloworld
  Containers:
   application1:
    Image:        avinashsi/tomcat:8.053_R2
    Port:         8080/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:
      /home/tomcat/webapps/app/ from mypvc (rw)
  Volumes:
   mypvc:
    Type:          HostPath (bare host directory volume)
    Path:          /home/vagrant/files/app_data/application1
    HostPathType:
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   tomcat1-deployment-66d78b9c6b (4/4 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  18m   deployment-controller  Scaled up replica set tomcat1-deployment-66d78b9c6b to 4
[root@minkube backend]#

```


Now that's give us the image as of now currently using the following image which has tomcat8.053

```
Image:avinashsi/tomcat:8.053_R2

```

Lets update the docker image which has tomcat9.0.11 which is being tagged as follows. avinashsi/tomcat:9.0.11_R3
and run the following sequence of commad to make sure we have updated version of docker image.

```
[root@minkube backend]# kubectl set image deployment/tomcat1-deployment application1=avinashsi/tomcat:9.0.11_R3
deployment.extensions/tomcat1-deployment image updated
[root@minkube backend]# kubectl get pods
NAME                                  READY     STATUS        RESTARTS   AGE
frontend                              1/1       Running       0          2h
tomcat1-deployment-66bb859686-7stxx   1/1       Running       0          22s
tomcat1-deployment-66bb859686-mxfrb   1/1       Running       0          28s
tomcat1-deployment-66bb859686-qcdxm   1/1       Running       0          29s
tomcat1-deployment-66bb859686-qx85v   1/1       Running       0          21s
tomcat1-deployment-66d78b9c6b-8kqzw   1/1       Terminating   0          29m
tomcat1-deployment-66d78b9c6b-hxmnp   1/1       Terminating   0          29m
tomcat1-deployment-66d78b9c6b-jnxwd   1/1       Terminating   0          29m
tomcat1-deployment-66d78b9c6b-p2wfs   1/1       Terminating   0          29m
[root@minkube backend]# kubectl describe deployments tomcat1-deployment
Name:                   tomcat1-deployment
Namespace:              default
CreationTimestamp:      Tue, 04 Sep 2018 16:57:50 -0400
Labels:                 app=tomcat1-helloworld
Annotations:            deployment.kubernetes.io/revision=2
Selector:               app=tomcat1-helloworld
Replicas:               4 desired | 4 updated | 4 total | 4 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:  app=tomcat1-helloworld
  Containers:
   application1:
    Image:        avinashsi/tomcat:9.0.11_R3
    Port:         8080/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:
      /home/tomcat/webapps/app/ from mypvc (rw)
  Volumes:
   mypvc:
    Type:          HostPath (bare host directory volume)
    Path:          /home/vagrant/files/app_data/application1
    HostPathType:
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   tomcat1-deployment-66bb859686 (4/4 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  30m   deployment-controller  Scaled up replica set tomcat1-deployment-66d78b9c6b to 4
  Normal  ScalingReplicaSet  1m    deployment-controller  Scaled up replica set tomcat1-deployment-66bb859686 to 1
  Normal  ScalingReplicaSet  1m    deployment-controller  Scaled down replica set tomcat1-deployment-66d78b9c6b to 3
  Normal  ScalingReplicaSet  1m    deployment-controller  Scaled up replica set tomcat1-deployment-66bb859686 to 2
  Normal  ScalingReplicaSet  1m    deployment-controller  Scaled down replica set tomcat1-deployment-66d78b9c6b to 2
  Normal  ScalingReplicaSet  1m    deployment-controller  Scaled up replica set tomcat1-deployment-66bb859686 to 3
  Normal  ScalingReplicaSet  1m    deployment-controller  Scaled down replica set tomcat1-deployment-66d78b9c6b to 1
  Normal  ScalingReplicaSet  1m    deployment-controller  Scaled up replica set tomcat1-deployment-66bb859686 to 4
  Normal  ScalingReplicaSet  1m    deployment-controller  Scaled down replica set tomcat1-deployment-66d78b9c6b to 0
[root@minkube backend]#

```


----
Summary .

We have Implemented a piece of software exposing a JSON document:
```
{
“id”: “1”,
“message”: “Hello world”
}
…
```

When visited with a HTTP client
We have Dockerize the application & Put the application to Minikube Kubernetes
created a second application, that utilizes the first and displays reversed message text
Automate deployment of the 2 applications using a script

 Explained, how to ensure running multiple instances of the application
 Explained, how you would organize regular application upgrades
