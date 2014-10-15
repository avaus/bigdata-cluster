# Note
This guide is meant for Linux environment. It has been tested on OS X 10.9.4 also.

# 1. The Avaus BigData cluster in nutshell

Bigdata -teams infrastructure automation tools.
This contains:

- [HDFS](http://hadoop.apache.org/) Distributed filesystem
- [Hadoop MapReduce](http://hadoop.apache.org/) Batch processing
- [YARN](http://hadoop.apache.org/) Workload management
- [HBase](https://hbase.apache.org/) Big data store **[not included yet]**
- [Hive](http://hive.apache.org/) Query and manage datasets
- [Shark](http://shark.cs.berkeley.edu/) **[not included yet]**
- [Spark](https://spark.incubator.apache.org/) Cluster computing **[not included yet]**
- [Mahout](https://mahout.apache.org/) Machine learning **[not included yet]**
- [Sqoop](http://sqoop.apache.org/) Transfer bulk data from/to databases **[not included yet]**
- [Hue](http://gethue.com/) Web UI **[not working yet]**
- [Solr](https://lucene.apache.org/solr/) Search in Hue UI **[not included yet]**
- [R](http://www.r-project.org/), [RStudio](http://www.rstudio.com/), and [Shiny](http://shiny.rstudio.com/) Machine learning

In this version, the cluster has one master (named 'data-master') and one slave (named 'data-slave') builders. When running locally, there will be 1 master node and 1 slave node. When running on Amazon, you can build one master node and n slave node(s).

# 2. Setup the environment

### Install Ruby
It is recommended to use RVM (Ruby Version Manager). For more details how to install Ruby, please see [here](https://www.ruby-lang.org/en/installation).

### Install Bundler
Bundler provides a consistent environment for Ruby projects by tracking and installing the exact gems and versions that are needed. Open a terminal window and run this command:

```bash
$ gem install bundler
```
### Install Vagrant
Vagrant provides easy to configure, reproducible, and portable work environments. Visit [here](https://docs.vagrantup.com/v2/installation/index.html) to learn how to install Vagrant.

VirtualBox must be installed on its own prior to using the provider, or the provider will display an error message asking you to install it. VirtualBox can be installed by [downloading](https://www.virtualbox.org/wiki/Downloads) a package or installer for your operating system and using standard procedures to install that package.

#### Install vagrant-omnibus plugin
This plugin ensures the desired verion of Chef. This proves very useful when using Vagrant with provisioner-less baseboxes OR cloud images. Run this command:

```bash
$ vagrant plugin install vagrant-omnibus
```

Note: this needs the nokogiri gem. So either [install nokogiri](http://nokogiri.org/tutorials/installing_nokogiri.html) gem or add ```s.add_dependency(%q<nokogiri>, ["= 1.6.2.1"])``` to ```/Applications/Vagrant/embedded/gems/specifications/vagrant-1.6.3.gemspec```.


### Install Berkshelf
Bershelf is a tool for managing cookbooks. You can install Berkshelf from Rubygems by running this command:

```bash
$ gem install berkshelf
```
Or add Berkshelf to your repository's Gemfile:

```bash
gem 'berkshelf'
```

Visit [here](http://berkshelf.com/index.html) to know more about installing Berkshelf.

### Install Packer
Packer is a tool for creating identical machine images from a single source configuration. With Packer, you can easily build images for Amazon EC2, DigitalOcean, VirtualBox and VMware. Visit [here](http://www.packer.io/docs/installation.html) to install Packer.

### Misc
Other tools might be needed such as [Git](http://git-scm.com/book/en/Getting-Started-Installing-Git).

# 3. Deployment

## 3.1. Get source code
The source code of the Avaus BigData cluster is available at [GitHub](https://github.com/avaus/bigdata-cluster).


## 3.2. Run locally
In this mode, there is 1 master and 1 slave.

### Update cookbooks
In the project folder, run this command:

```bash
berks update
berks vendor
```
Cookbooks will be in berks-cookbooks folder. If the 'berks-cookbooks' folder already exists, and you want to renew it, remember to remove the folder:

```bash
berks update
rm -r berks-cookbooks
berks vendor
```

Now you can start the machines. In the project folder, run this command:

```bash
vagrant up
```

It the first time, this command builds the machines. After that, this command is to turn on the machines. Please visit [Vagrant's website](https://docs.vagrantup.com/v2/getting-started/index.html) to learn how to etc. suspend, halt and destroy machines. 
When the building is completed (for the first time of running vagrant up) or the machines are turned one, you can access 

- Hue Web UI at http://data-master-ip:8888
- Hadoop Administration at http://data-master-ip:50070
- MapReduce information at http://data-master-ip:8088

The data-master-ip is set in the Vagrantfile, and is 192.168.60.2 by default.

### To access server through SSH
#### Master server

Login to the master server with:

```Bash
vagrant ssh data-master
```
There should be NameNode, ResourceManager (Hadoop) and RunJar (Hue) services running. Check that by using:

```Bash
sudo jps
```

#### Slave server
Login to the slave server with:

```Bash
vagrant ssh data-slave
```
There should be NodeManager and DataNode services running. Check that by using:

```Bash
sudo jps
```
#### Services management
The related services include  resourcemanager, namenode, hiveserver2, derby and hue (in data-master) and nodemanager, datanode (in data-slave).

In ubuntu, you can manage services by these commands:

```Bash
sudo service xxx start/restart/stop/status
```

## 3.3. Run on Amazon

First, you have to build images using Packer. Then you create server instances from the built images. Any changes in configuration cause us to rebuild images and recreate instances.

This tutorial assumes that users have basic knowledge of AWS, such as how to create instances, how to create/use security groups and how to use AWS's keys.

### 3.3.1. Security groups

Create new security groups and select them whenever starting a new server instance. Allow the following traffic at least from your company network
- Inbound TCP 22 (SSH)						(1)
- Inbound TCP 8888 (Hue UI)				(2)
- Inbound TCP 50070 (Hadoop UI) 	(3)

The master needs all the above while the slaves need (1).

### 3.3.2. Build images

First you need to create machine images (AMIs) to under your AWS account.

To automate building the images, you can use [Packer](http://www.packer.io/) with the following commands:

```bash
# Install Packer if you don't have it:
# http://www.packer.io/docs/installation.html

# Setup Amazon access key environment variables
# (Change your own access and private keys)
export AWS_ACCESS_KEY=your_access_key
export AWS_SECRET_KEY=your_private_key

# Build data-master image
packer build packer/data-master.json

# Repeat the 'packer build' for each file in the packer -directory
# (You can run them same time to speedup the building)
```

### 3.3.3. Start instances

For whole cluster you need to create following machines:
- 1 x data-master (at least medium instance)
- n x data-slave (one or more slaves)

#### a. Start master instance

First you need to start the master node.

1. Go to Amazon AWS console > ec2 > images, select "data-master" image then click on Launch
2. Choose a suitable instance type
3. Configue Instance: You can define IP for data-master here then go to step 4. Otherwise skip step 4, the data-master's IP will be assigned automatically
4. Whenever the data-master's IP is known, go to "Advanced Details" > "User data" and copy/paste content from host.sh (see 3.3.4). **Remember replace the x.x.x.x with the data-master's IP address**
5. Go through the next steps, including selecting your security group(s) what you created in the pre-step! 
7. Launch it!
8. Pick up the private ip address of the brand new machine, you will need it when you start the slave machine(s)
9. If step 4 was not done yet, we have to access to the data-master and manually add the data master node's IP address to etc/hosts. Then restart namenode and resourcemanager services.

```bash
sudo sh -c "echo 'x.x.x.x data-master' >> /etc/hosts"
sudo service namenode restart
sudo service resourcemanager restart

```

#### b. Start slave machine(s)

When you start slave machine, you need to setup "user-data", that is, script what to run at startup. In the startup script, you have to make the slave connect to the master by writing the master machine ip address to the /etc/hosts file.

1. Go to Amazon AWS console > ec2 > images, select "data-master" image then click on Launch
2. Choose a suitable instance type
3. Select "Advanced Details" > "User data" and copy/paste content from host.sh (see 3.3.4). **Remember replace the x.x.x.x with the data-master's IP address**
6. Continue through all steps and select your security group(s) what you created in the pre-step! 
7. Launch it!

### 3.3.4 hosts_for_master.sh

This is example of user data what you need to setup when you're starting up slave node. Basically what it does is that it will configure data-master ip address and restart required services.

```bash
#!/bin/bash
# NOTE:
# replace x.x.x.x with your current
# data-master private ip address
#

echo "X.X.X.X data-master" >> /etc/hosts
sudo service namenode restart
sudo service resourcemanager restart

```

### 3.3.4.1 hosts_for_slaves.sh

This is example of user data what you need to setup when you're starting up slave node. Basically what it does is that it will configure data-master ip address and restart required services.

```bash
#!/bin/bash
# NOTE:
# replace x.x.x.x with your current
# data-master private ip address
#

echo "X.X.X.X data-master" >> /etc/hosts
sudo service datanode restart
sudo service nodemanager restart

```


### 3.3.5. It's ready!
Now you can try to go to [http://master-ip-address:50070](http://master-ip-address:50070) Hadoop UI and verify that the master can see the slave machine.
Also you should be able to login to Hue [http://master-ip-address:8888](http://master-ip-address:8888) (use for example 'hue' username). From Hue, you can browse the HDFS, work with Hive and visualize the query results. See [here](http://gethue.com/) to learn how to use Hue.

You will see the master-ip-address (public DNS) in the Amazon EC2 console.

In [http://master-ip-address:8088](http://master-ip-address:8088), you can monitor the mapreduce jobs.

### 3.3.6. To access server through SSH

You have to include the .pem file obtained from Amazon to access the data master server. An example ssh command to access the server:

```bash
#!/bin/bash
ssh -i Amazon.pem ubuntu@ec2-12-34-567-890.eu-west-1.compute.amazonaws.com
```

Login to the master server and slaves using user 'ubuntu'. You can then switch to 'hadoop' user to run scripts in Hadoop

```Bash
sudo su - hadoop
```
When logged in, you can use [HDFS commands](http://hadoop.apache.org/docs/r0.18.3/hdfs_shell.html) to work with the HDFS.


# 4. Development
## 4.1 Add new cookbook

How to add new Chef cookbook to this project?

This project uses [Berkshelf](http://berkshelf.com/) for managing cookbooks.

### Add cookbook to Berksfile
Add your cookbook git repository url to Berksfile.

Berksfile

```ruby
cookbook 'my-cookbook', git: 'https://github.com/someuser/my-cookbook.git'
```

### Update cookbooks
Run Berks command to download your cookbook.

```bash
# Remove all cookbooks
rm -rf berks-cookbooks

# Update cookbook versions
berks update

# Download cookbooks
berks vendor
```

After this your cookbook should be found in berks-cookbooks -directory.

#### Add recipe from cookbook to Chef role

Next to make the Chef run something from given cookbook, you need to add recipe to some Chef role. For example `my-cookbook` contains `my-recipe` -recipe and you want to run it in `data-master` -machines.

Add recipe to `provision/roles/data-master` -file

```ruby
run_list "recipe[some-other]", "recipe[my-recipe]"
```

#### [Optional] Set recipe attributes
Quite often you need to set some attributes for the recipe. You can do it in roles-file.

Add attributes to `provision/roles/data-master`-file

```ruby
default_attributes "my-tool" => {
    'some-attribute' => 'some-value',
}
```

#### Provision virtual machine
To make change affect lets re-run provisioning.

```bash
vagrant provision
# ... Or if not VM up yet ...
vagrant up --provision
```

Now you should see all the changes in the VM.

## 4.2 Dependencies

You can specify all dependencies in the repository's Gemfile and install them by running this command from the parent directory

```bash
$ bundle install
```


License and Authors
-------------------
Authors: [Erno Aapa](https://github.com/eaapa), Kimi Ylilammi, [Hung Ta](https://github.com/hungtx)
License: [MIT](http://opensource.org/licenses/MIT)

## 5. Examples

Examples of running Hadoop scripts, R, H2O, and other stuff on this bigdata cluster can be found in [GitHub](https://github.com/avaus/bigdata-examples).
