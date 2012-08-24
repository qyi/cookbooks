include_recipe "libv8"
include_recipe "git"
include_recipe "build-essential"
include_recipe "npm"
include_recipe "libssl"
include_recipe "libxml"

npm_package "sm"

execute "install cloud9" do
  cwd "/usr/lib/node_modules"
  command <<-CMD
    sm clone https://github.com/ajaxorg/cloud9/tree/master cloud9
    #cd cloud9 && sudo sm update
  CMD
  not_if { File.exists? "/usr/lib/node_modules/cloud9" }
end

if node['cloud9']['init'] == "runit"
  runit_service "cloud9"
end