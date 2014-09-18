name "rstudio"
description "RStudio installation"

run_list "recipe[rstudio::server]"
run_list "recipe[rstudio::shiny]"


override_values = {
  'platform' => 'ubuntu'
}

default_attributes override_values
