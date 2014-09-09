name "hue"
description "Server running Hue UI"

run_list "recipe[hue]"

override_values = {
  'java' => {
    'jdk_version' => '7'
  },
  'hue' => {

  }
}

default_attributes override_values
