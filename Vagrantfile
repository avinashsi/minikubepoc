# -*- mode: ruby -*-
# vi: set ft=ruby :

# you're doing.
Vagrant.configure("2") do |config|
	config.vm.define :minikube do |minikube|
		minikube.vm.hostname = "minkube.test.com"
		minikube.vm.box = "minikubepoc"
		minikube.vm.boot_timeout = 300

		minikube.vm.network :private_network, ip: "192.168.111.11"
		minikube.vm.network "forwarded_port", guest: 1024, host: 80,auto_correct: true
		minikube.vm.network "forwarded_port", guest: 1025, host: 81,auto_correct: true
		minikube.vm.network "forwarded_port", guest: 1026, host: 82,auto_correct: true
		minikube.vm.network 	"forwarded_port", guest: 30000,host: 30000,auto_correct: true

		minikube.vm.provision "shell" , path: "bootstrap.sh"
	  minikube.vm.synced_folder "files", "/home/vagrant/files"

		minikube.vm.provider "virtualbox" do |prov|
			prov.customize ["modifyvm", :id, "--memory", "2048"]
			prov.gui=true
			prov.name="minikube"
		end
	end
end
