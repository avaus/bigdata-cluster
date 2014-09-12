name "rstudio"
description "RStudio installation"

run_list "recipe[rstudio::server]"

override_values = {
  'platform' => 'ubuntu'
}

default_attributes override_values
