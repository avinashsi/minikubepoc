MiniKube Poc
=========

Getting started
---------------
Note: This Poc is done on Windows10 .
Download [Vagrant](https://releases.hashicorp.com/vagrant/2.0.0/vagrant_2.0.0_x86_64.msi).
Download [Vagrant Redhat Box] (https://gitlab.com/avinashsi/boxes/blob/master/puppet_rhel7.box)

Install Vagrant and Restart Your system after Installation

Add Vagrant Box in your system Go to donwnload directory where you have donwnloaded box:

```
vagrant box add --name minikubepoc /path/to/box/puppet_rhel7.box
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


Architecture
-----




Note
----
