Vagrant.configure("2") do |config|
  config.vm.box = "puppetlabs/ubuntu-16.04-64-puppet"
  config.vm.box_check_update = false
  config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1", id: 'ssh_apache'
  config.vm.network "forwarded_port", guest:3306, host:3306, host_ip: "127.0.0.1", id: 'ssh_mysql'
  config.vm.hostname = "vm.example.local"
  config.vm.synced_folder "./", "/var/www" , owner: "www-data", group: "www-data"

  config.vm.provider :virtualbox do |v|
	v.customize [
	"modifyvm",:id,
	"--name","vm-example",
	"--memory",768,
	"--cpus",2
	]
  end

  config.vm.provision :shell, inline: <<-SHELL

    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7F438280EF8D349F
    apt-get update -y --fix-missing

    puppet module install puppetlabs-apache --version 1.11.0 --target-dir /tmp/vagrant-puppet/modules*
    puppet module install puppetlabs-firewall --version 1.8.2 --target-dir /tmp/vagrant-puppet/modules*
    puppet module install mayflower-php --version 4.0.0-beta1 --target-dir /tmp/vagrant-puppet/modules*
    puppet module install puppetlabs-mysql --version 3.10.0 --target-dir /tmp/vagrant-puppet/modules*
    puppet module install saz-memcached  --version 3.0.1 --target-dir /tmp/vagrant-puppet/modules*

    curl -sS https://getcomposer.org/installer > composer.phar
    mv composer.phar /usr/local/bin/composer

  SHELL

  config.vm.provision :puppet do |puppet|
	puppet.environment_path = "puppet/environments"
	puppet.environment = "develop"
	puppet.module_path = "puppet/modules"
	puppet.options = "--disable_warnings=deprecations"
  end
end