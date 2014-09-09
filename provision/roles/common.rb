name "common"
description "Common recipes for all servers"

# Apt recipe to run 'apt-get update'
run_list "recipe[apt]"
