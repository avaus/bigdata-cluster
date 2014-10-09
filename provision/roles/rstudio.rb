name "rstudio"
description "RStudio installation"

# Install RStudio Server and Shiny Server
run_list "recipe[rstudio::server]",
         "recipe[rstudio::shiny]"


override_values = {
  'platform' => 'ubuntu'
}

default_attributes override_values
