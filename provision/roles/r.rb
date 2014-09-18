name "r"
description "R installation"

# Install R
run_list "recipe[r::default]"
# Install packages listed in this recipe
run_list "recipe[r::install_r-packages]"

override_values = {
  'platform_family' => 'ubuntu',
  # 'r' => {
  #    'version' => '3.1.1',
  #    'checksum' => 'ce5c4d5e34414ce8f1ec2d5642861435fa1ddc4cd89bd336172bbe25a62c7a19'
  #  }
}

default_attributes override_values
