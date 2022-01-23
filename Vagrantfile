#number of worker nodes
NUM_WORKERS = 3
# number of extra disks per worker
NUM_DISKS = 1
# size of each disk in gigabytes
DISK_GBS = 203

KUBERNETES_VERSION = "1.22.5"

ENV["VAGRANT_EXPERIMENTAL"] = "disks"

MASTER_IP = "192.168.73.100"
WORKER_IP_BASE = "192.168.73.2" # 200, 201, ...
TOKEN = "yi6muo.4ytkfl3l6vl8zfpk"

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provision "shell", path: "common.sh",
    env: { "KUBERNETES_VERSION" => KUBERNETES_VERSION }

  config.vm.provision "shell", path: "local-storage/create-volumes.sh"
  config.vm.disk :disk, size: "25GB", primary: true


  
  config.vm.define "master" do |master|

    master.vm.provider "virtualbox" do |v|
      v.memory = 6144
      v.cpus = 2
      v.name = "master.calvarado04.com"
      v.check_guest_additions = false
      v.gui = false
      v.customize ["modifyvm", :id, "--audio", "none"]
      v.customize ["modifyvm", :id, "--chipset", "ich9"]
      v.customize ["modifyvm", :id, "--paravirtprovider", "kvm"]
      v.customize ['modifyvm', :id, "--graphicscontroller", "vmsvga"]
      v.default_nic_type = "virtio"
    end    

    master.vm.hostname = "master.calvarado04.com"

    master.vm.network "private_network", ip: MASTER_IP

    master.vm.provision :file do |file|
      file.source = "calico.yml"
      file.destination = "/tmp/calico.yml"
    end

    master.vm.provision "shell", path: "master.sh",
      env: { "MASTER_IP" => MASTER_IP, "TOKEN" => TOKEN, "KUBERNETES_VERSION" => KUBERNETES_VERSION }

    master.vm.provision :file do |file|
      file.source = "local-storage/storageclass.yaml"
      file.destination = "/tmp/local-storage-storageclass.yaml"
    end
    master.vm.provision :file do |file|
      file.source = "local-storage/provisioner.yaml"
      file.destination = "/tmp/local-storage-provisioner.yaml"
    end
    master.vm.provision "shell", path: "local-storage/install.sh"
   
    master.vm.provision :file do |file|
      file.source = "portworx-enterprise.yaml"
      file.destination = "/tmp/portworx-enterprise.yaml"
    end



    master.vm.provision "shell", path: "portworx.sh"
  end

  (0..NUM_WORKERS-1).each do |i|
    config.vm.define "worker#{i}" do |worker|


      worker.vm.network "private_network", ip: "#{WORKER_IP_BASE}" + i.to_s.rjust(2, '0')

      worker.vm.provider "virtualbox" do |v|
        v.memory = 12288
        v.cpus = 2
        v.name = "worker#{i}.calvarado04.com"
        v.check_guest_additions = false
        v.gui = false
        v.customize ["modifyvm", :id, "--audio", "none"]
        v.customize ["modifyvm", :id, "--chipset", "ich9"]
        v.customize ["modifyvm", :id, "--paravirtprovider", "kvm"]
        v.customize ['modifyvm', :id, "--graphicscontroller", "vmsvga"]
        v.default_nic_type = "virtio"
        unless File.exist?("disks/worker#{i}-disk-kvdb.vdi") 
          #v.customize ["storagectl", :id, "--name", "SATA Controller", "--add", "sata", "--portcount", "2", "--hostiocache", "on" ]
          v.customize ["createmedium", "disk", "--filename", "disks/worker#{i}-disk-kvdb", "--format", "VDI", "--size", "51200"]
          v.customize ["storageattach", :id,  "--storagectl", "SCSI", "--port", 2, "--device", 0, "--type", "hdd", "--nonrotational", "on", "--medium", "disks/worker#{i}-disk-kvdb.vdi" ]
          (1..NUM_DISKS).each do |j|
            v.customize ["createmedium", "disk", "--filename", "disks/worker#{i}-disk-0#{j}", "--format", "VDI", "--size", "203000"]
            v.customize ["storageattach", :id,  "--storagectl", "SCSI", "--port", 3, "--device", 0, "--type", "hdd", "--nonrotational", "on", "--medium", "disks/worker#{i}-disk-0#{j}.vdi" ]
          end
        end
      end    

      worker.vm.hostname = "worker#{i}.calvarado04.com"


      worker.vm.provision "shell", path: "worker.sh",
        env: { "MASTER_IP" => MASTER_IP, "TOKEN" => TOKEN }
    end
  end

end
