# Add new cookbook

How to add new Chef cookbook to this project.

This project uses [Berkshelf](http://berkshelf.com/) for managing cookbooks.

## Add cookbook to Berksfile
Add your cookbook git repository url to Berksfile.

Berksfile

```ruby
cookbook 'my-cookbook', git: 'https://github.com/someuser/my-cookbook.git'
```

## Update cookbooks
Run Berks command to download your cookbook.

```bash
# Remove all cookbooks
rm -rf berks-cookbooks

# Update cookbook versions
berks update

# Download cookbooks
berks vendor
```

After this your cookbook should be found in berks-cookbooks -directory.

### Add recipe from cookbook to Chef role

Next to make the Chef run something from given cookbook, you need to add recipe to some Chef role. For example `my-cookbook` contains `my-recipe` -recipe and we wan't to run it in `data-master` -machines.

Add recipe to `provision/roles/data-master` -file

```ruby
run_list "recipe[some-other]", "recipe[my-recipe]"
```

### [Optional] Set recipe attributes
Quite often you need to set some attributes for the recipe. You can do it in roles-file.

Add attributes to `provision/roles/data-master`-file

```ruby
default_attributes "my-tool" => {
    'some-attribute' => 'some-value',
}
```

### Provision virtual machine
To make change affect lets re-run provisioning.

```bash
vagrant provision
# ... Or if not VM up yet ...
vagrant up --provision
```

Now you should see all the changes in the VM.
