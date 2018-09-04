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


Architecture
-----




Note
----
