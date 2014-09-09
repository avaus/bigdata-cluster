# How to setup big data cluster to Amazon
This document describes steps needed to setup new big-data cluster to AWS (Amazon Web Services).

> Note: If you make any changes to the configurations, you need to do re-build the images and re-create servers.

## 1. Pre-steps
It's much easier to manage the cluster in Amazon if you create security group for your servers and
when you start new server instance, select the created security group rather than every time create
new security group.

Create new security group and allow following traffic at least from your company network
- Inbound TCP 22 (SSH)
- Inbound TCP 8888 (Hue UI)
- Inbound TCP 50070 (Hadoop UI)

## 2. Build images
First you need to create machine images (AMIs) to under your AWS account.

To automate building the images we use [Packer](http://www.packer.io/).

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
## 3. Start instances
For whole cluster you need to create following machines:
- 1 x data-master (at least medium instance)
- n x data-slave (one or more slaves)

#### Start master instance
First you need to start master node.
1. Go to Amazon AWS console
2. Go to ec2 > images
3. Select "data-master" image
4. NOTE: Now you should go through all steps and select your security group(s) what you created in the pre-step! 
5. Launch it!

Pick up the private ip address of the brand new machine, you will need it when you start slave machine.

#### Start slave machine(s)
When you start slave machine, you need to setup "user-data" aka. script what to run at startup.
In the startup script, we will make small trick to make the slave connect to the master.
We write the master machine ip address to the /etc/hosts file.

1. Go to Amazon AWS console
2. Go to ec2 > images
3. Select "data-slave" image
4. Now in second step select "Advanced Details"
5. There under the "user data" section copy/paste content from [data-slave_use-data.sh](../blob/master/docs/data-slave_user-data.sh). **Remember replace the x.x.x.x with master server ip address**
6. Continue through all steps and select your security group(s) what you created in the pre-step! 
7. Launch it!

### 4. It's ready!
Now you can try to go to [http://master-ip-address:50070](http://master-ip-address:50070) Hadoop UI and verify that master see the slave machine.
Also you should be able to go login to Hue [http://master-ip-address:8888](http://master-ip-address:8888)
