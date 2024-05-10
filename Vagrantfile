Vagrant.configure("2") do |config|
  config.vm.provision :shell, inline: "echo 'Vagrant VMs creation - START!!'"

  config.vm.synced_folder '.', '/vagrant', disabled: true

  config.vm.define "master", primary: true do |master|
    master.vm.provision :shell, inline: "sudo yum update -y && sudo yum upgrade -y && sudo yum update -y && sudo yum upgrade -y && echo 'Master node creation!!'"
    master.vm.hostname = "master"
    master.vm.box = "eurolinux-vagrant/oracle-linux-8"
    master.vm.network "private_network", ip: "192.168.50.10"
    master.vm.provider "virtualbox" do |virtualbox|
      virtualbox.memory = 5120
      virtualbox.cpus = 3
    end
  end

  config.vm.define "worker" do |worker|
    worker.vm.provision :shell, inline: "sudo yum update -y && sudo yum upgrade -y && sudo yum update -y && sudo yum upgrade -y && echo 'Worker node creation!!'"
    worker.vm.hostname = "worker"
    worker.vm.box = "eurolinux-vagrant/oracle-linux-8"
    worker.vm.network "private_network", ip: "192.168.50.11"
    worker.vm.provider "virtualbox" do |virtualbox|
      virtualbox.memory = 5120
      virtualbox.cpus = 3
    end
  end

  # config.vm.define "worker2" do |worker2|
  #   worker2.vm.provision :shell, inline: "sudo yum update -y && sudo yum upgrade -y && sudo yum update -y && sudo yum upgrade -y && echo 'Worker2 node creation!!'"
  #   worker2.vm.hostname = "worker2"
  #   worker2.vm.box = "eurolinux-vagrant/oracle-linux-8"
  #   worker2.vm.network "private_network", ip: "192.168.50.12"
  #   worker2.vm.provider "virtualbox" do |virtualbox|
  #     virtualbox.memory = 5120
  #     virtualbox.cpus = 2
  #   end
  # end

  config.vm.provision :shell, inline: "echo 'Vagrant VMs creation - END!!'"
end