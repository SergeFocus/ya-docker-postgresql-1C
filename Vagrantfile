# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "bessonovevgen/ubuntu-server-16"

  @provider = "virtualbox"
  
  # config.vm.provider "hyperv" do |v, override|
  #   override.vm.box = "kmm/ubuntu-xenial64"
  #   @provider = "hyperv"
  # end

  # @dockeruser = if (@provider == "virtualbox") ; then "ubuntu" else "vagrant" end
  @dockeruser = "vagrant"

  config.vm.box_check_update = false
  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "vanessa-dockers/pgsteroids"
  # end
  config.vm.define "docker" do |docker|
      docker.vm.hostname = "docker"
      docker.vm.network "forwarded_port", guest: 5432, host: 5432
      docker.vm.network "forwarded_port", guest: 8081, host: 8081
      docker.vm.network "forwarded_port", guest: 8888, host: 8888
      docker.vm.network "forwarded_port", guest: 9997, host: 9997
      docker.vm.network "forwarded_port", guest: 9998, host: 9998
      docker.vm.network "forwarded_port", guest: 9999, host: 9999
      docker.vm.provider "virtualbox" do |vb|
         vb.memory = "4096"
         vb.name = "docker"
      end

      docker.vm.provider "hyperv" do |hv|
        hv.vmname  = "docker"
      end
    # run the provisioning only is the first 'vagrant up'
    # config.vm.provision :shell, :inline = @
    if Dir.glob("#{File.dirname(__FILE__)}/.vagrant/machines/first/" + @provider + "/id").empty?
      #   Install Docker
      pkg_cmd = "curl -sSL https://get.docker.com/ | sh;"
      #   Add user to the docker group and install packadges
      pkg_cmd << "usermod -a -G docker " + @dockeruser + " ; "
      pkg_cmd << "apt-get update -y -q; "
      pkg_cmd << "apt-get install dnsmasq python3-pip python-psycopg2 libdbd-pg-perl libdbi-perl docker-compose mc -y -q; "
      config.vm.provision :shell, :inline => pkg_cmd
    end
  end
end
