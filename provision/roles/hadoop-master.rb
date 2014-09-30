name "hadoop-master"
description "Master server in Hadoop cluster"

run_list  "recipe[hadoop::namenode]",
          "recipe[hadoop::resourcemanager]"

override_values = {
  'hadoop' => {
    'webhdfs' => true,
    'core_configs' => {
      'hadoop.proxyuser.hue.hosts' => '*',
      'hadoop.proxyuser.hue.groups' => '*'
    },
    'permissions'  =>  true,
    'rpc_bind_host'  =>  '0.0.0.0',
    'namenode' => {
      'host' => 'data-master',
      'tracker' => 'data-master:54311'
    },
    'resourcemanager' => {
      'host' => 'data-master'
    },
    'datanode' => {
      'data_dir' => '/opt/hadoop/datanode/'
    },
    'namenode' => {
      'name_dir' => '/opt/hadoop/namenode/'
    },
    'mapreduce' => {
      'framework' => 'yarn'
    }
  }
}

default_attributes override_values
