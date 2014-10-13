name "mahout"
description "Server running Mahout, a statistical framework for BigData"

run_list "recipe[mahout::default]"

override_values = {
  'java' => {
    'jdk_version' => '7'
  }
}

default_attributes override_values