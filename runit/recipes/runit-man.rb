
::Chef::Recipe.send(:include,Opscode::OpenSSL::Password)

include_recipe "runit"

node.set_unless[:runit][:runit_man][:password] = secure_password
node.save unless Chef::Config[:solo]
  
gem_package "runit-man" do
  action :install
end
  
gem_package "thin" do
  action :install
  notifies :start, "service[runit-man]"
end
  
runit_service "runit-man"
