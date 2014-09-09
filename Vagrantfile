# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

# Ensure have vagrant-omnibus -plugin
if !Vagrant.has_plugin?('vagrant-omnibus')
  raise "vagrant-omnibus -Vagrant plugin is required. Please run: vagrant plugin install vagrant-omnibus"
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Ubuntu box from http://opscode.github.io/bento/
  config.vm.box = 'ubuntu-14.04'
  config.vm.box_url = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04_chef-provisionerless.box'

  # Ensure box have latest Chef installed
  config.omnibus.chef_version = :latest

  ### COMMON CONFIGS TO ALL VMs
  # VM resources
  config.vm.provider "virtualbox" do |vm|
    vm.memory = 1536
  end

  # To avoid hard coding IPs we use hosts file to map service to ip address
  config.vm.provision :shell do |shell|
    shell.path = "provision/scripts/add_host.sh"
    shell.args = ["data-master", "192.168.60.2"]
  end

  ### BUILD CONIFGS FROM PACKER JSON CONFIGS
  Dir.glob('packer/*.json').each_with_index do |packer_file, index|
    filename = File.basename(packer_file, '.*')

    # Create new VM by filename
    config.vm.define filename.to_s do |config|

      # Read Packer configs
      packer_config = JSON.parse(IO.read(packer_file))

      # Set VM ip address
      config.vm.network :private_network, ip: "192.168.60.#{index+2}"
      # Set hostname
      config.vm.hostname = filename

      packer_config['provisioners'].each do |provisioner|

        case provisioner['type']
        when 'chef-solo'
          # Create Chef-solo configuration
          config.vm.provision :chef_solo do |chef|
            chef.cookbooks_path = provisioner['cookbook_paths'] if !provisioner['cookbook_paths'].nil?
            chef.roles_path = provisioner['roles_path'] if !provisioner['roles_path'].nil?
            chef.data_bags_path = provisioner['data_bags_path'] if !provisioner['data_bags_path'].nil?

            provisioner['run_list'].each do |run_item|
              if run_item =~ /^role/
                chef.add_role run_item
              elsif run_item =~ /^recipe/
                chef.add_recipe run_item
              else
                raise "Unkown run_list item #{run_item}. Cannot configure Chef-solo!"
              end
            end

            # Chef configurations
            # Note: only Vagrant specific configurations here.
            # Image specific should go to Packer json -file.
            chef.json = provisioner['json'].deep_merge({
              'hadoop' => {
                # Disable hostname check because we don't have DNS server
                # in Vagrant setup
                'ip_hostname_check' => false,
              },
              "hue" => {
                # This might not be needed anymore...
                "webhdfs_url" => "http://data-master:50070/webhdfs/v1"
              }
            })

          end

        else
          raise 'Unknown provisioner type #{provisioner["type"]} in #{filename}. Cannot create Vagrant configs from it!'
        end

      end

    end

  end

end

##
# Hash deep-mege support
# We need deep merge support when we merge packer json with Vagrant specific json content

class ::Hash
    def deep_merge(second)
        merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
        self.merge(second, &merger)
    end
end
