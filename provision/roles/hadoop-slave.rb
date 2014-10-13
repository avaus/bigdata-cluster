name "hadoop-slave"
description "Slave server in Hadoop cluster"

run_list "recipe[hadoop::datanode]",
				 "recipe[hadoop::nodemanager]"

override_values = {
  'java' => {
    'jdk_version' => '7'
  },
  'hadoop' => {
    'webhdfs' => true,
    'core_configs' => {
      'hadoop.proxyuser.hue.hosts' => '*',
      'hadoop.proxyuser.hue.groups' => '*'
    },
   'namenode' => {
      'name_dir' => '/opt/hadoop/namenode',
      'host' => 'data-master',
      'tracker' => 'data-master:54311'
    },
   'resourcemanager' => {
      'host' => 'data-master'
    },
   'datanode' => {
      'data_dir' => '/opt/hadoop/datanode'
    },
    'mapreduce' => {
      'framework' => 'yarn'
    }
  },
  'mahout' => {
    'hadoop2_version' => '2.4.0'
  }
}

default_attributes override_values