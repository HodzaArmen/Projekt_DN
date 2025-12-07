Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.hostname = "todoapp"

  config.vm.network "forwarded_port", guest: 5000, host: 5000

  config.vm.synced_folder ".", "/vagrant"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.gui = false
  end
  config.vm.boot_timeout = 600
  config.vm.provision "shell", path: "ukazi.sh"
end
