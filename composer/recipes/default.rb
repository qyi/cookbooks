
include_recipe "php"

package "curl"

remote_file "/usr/local/bin/composer.phar" do
  source "http://getcomposer.org/download/#{node['composer']['version']}/composer.phar"
  mode   "0644"
  not_if { File.exists? "/usr/local/bin/composer.phar" }
end

template "/usr/local/bin/composer" do
  owner  "root"
  group  "root"
  mode   "0755"
  source "composer.erb"
  variables(
    :phpbin_path => "/usr/local/bin"
  )
end
  