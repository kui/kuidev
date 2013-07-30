# -*- mode: ruby -*-

Vagrant.configure("2") do |config|

  config.vm.hostname = 'vagrant-kuidev'
  config.vm.box = 'precise64'
  config.vm.box_url = 'http://files.vagrantup.com/precise64.box'

  config.vm.network :forwarded_port, guest: 80, host: 8080

  # config.vm.network :public_network
  # config.vm.synced_folder "../data", "/vagrant_data"

  # require `vagrant plugin install vagrant-berkshelf`
  config.berkshelf.enabled = true

  # require `vagrant plugin install vagrant-omnibus`
  config.omnibus.chef_version = :latest

  # require `vagrant gem install vagrant-vbguest`
  if defined? VagrantVbguest
    config.vbguest.auto_update = true
  end

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      :mysql => {
        :server_root_password => 'rootpass',
        :server_debian_password => 'debpass',
        :server_repl_password => 'replpass'
      }
    }

    chef.run_list = [
        "recipe[kuidev::default]"
    ]
  end
end
