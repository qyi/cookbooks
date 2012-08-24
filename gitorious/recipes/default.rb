#
# Cookbook Name:: gitorious
# Recipe:: default
#
# Copyright 2011, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

::Chef::Recipe.send(:include,Opscode::OpenSSL::Password)
::Chef::Recipe.send(:include,Chef::RVM::StringHelpers)

include_recipe "rvm"
include_recipe "build-essential"
include_recipe "zlib"
include_recipe "nginx::source"
include_recipe "database"
include_recipe "imagemagick"
include_recipe "stompserver"
include_recipe "sphinx"
include_recipe "xml"
include_recipe "git"


node.set_unless[:gitorious][:db][:password] = secure_password
node.save unless Chef::Config[:solo]

%w{ libmagick++-dev libxslt1-dev tcl-dev postfix apg geoip-bin libgeoip-dev sqlite3 libsqlite3-dev libonig-dev libyaml-dev libopenssl-ruby libdbd-mysql-ruby git-cvs zip unzip memcached git-core git-svn git-doc libaspell-dev aspell-en curl libcurl4-openssl-dev }.each do |pkg|
  package pkg
end

user node[:gitorious][:app_user] do
  system true
  home node[:gitorious][:app_base_dir]
  shell "/bin/bash"
end

group node[:gitorious][:app_user] do
  members [ node[:gitorious][:app_user] ]
  append true
end

directory node[:gitorious][:app_base_dir] do
  recursive true
  owner node['gitorious']['app_user']
  group node['gitorious']['app_user']
  not_if { File.exists? node['gitorious']['app_base_dir'] }
  mode 0755
end

git node[:gitorious][:app_base_dir] do
  repository "git://gitorious.org/gitorious/mainline.git"
  enable_submodules true
  action :sync
  not_if { File.exists? "#{node[:gitorious][:app_base_dir]}/.git" }
end

bash "user_chown" do
  code "chown -R #{node[:gitorious][:app_user]}:#{node[:gitorious][:app_user]} #{node[:gitorious][:app_base_dir]}"
end

template "#{node['gitorious']['app_base_dir']}/.rvmrc" do
  source "rvmrc.erb"
  cookbook "rvm"
  owner node['gitorious']['app_user']
  group node['gitorious']['app_user']
  mode        "0644"
  variables   :system_install   => false,
              :rvm_path         => "#{node['gitorious']['app_base_dir']}/.rvm",
              :rvm_gem_options  => node['rvm']['rvm_gem_options'],
              :rvmrc            => Hash.new
  action :create
end
                
execute "install rvm for gitorious" do
  user node['gitorious']['app_user']
  command <<-CODE
    bash -c "bash -s stable < <(curl -s #{node['rvm']['installer_url']} )"
  CODE
  environment({ 'USER' => node['gitorious']['app_user'], 'HOME' => node['gitorious']['app_base_dir'] })
  action :run
  not_if  "test -d #{node['gitorious']['app_base_dir']}/.rvm"
  returns [0,1]
end

rvm_ruby node['gitorious']['rvm_ruby'] do
  user node['gitorious']['app_user']
  action :install
end

rvm_gemset node[:gitorious][:rvm_gemset] do
  ruby_string node['gitorious']['rvm_ruby']
  user node['gitorious']['app_user']
  action      :create
end

#daemons
%w{ rake rmagick stompserver bundler raspell passenger }.each do |gem|
  rvm_gem gem do
    ruby_string node['gitorious']['rvm_ruby_string']
    user node['gitorious']['app_user']
    action      :install
  end
end

rvm_environment node['gitorious']['rvm_ruby_string'] do
  ruby_string node['gitorious']['rvm_ruby_string']
  user node['gitorious']['app_user']
end

template "#{node['gitorious']['app_base_dir']}/.bashrc" do
  source "bashrc.erb"
  owner node['gitorious']['app_user']
  group node['gitorious']['app_user']
  mode  0644
end

link "/usr/bin/gitorious" do
  to "#{node[:gitorious][:app_base_dir]}/script/gitorious"
end

cookbook_file "#{node[:gitorious][:app_base_dir]}/Gemfile" do
  source      "Gemfile"
  owner  node[:gitorious][:app_user]
  group node[:gitorious][:app_user]
end

template "/etc/init.d/git-ultrasphinx" do
  source      "git-ultrasphinx.erb"
  mode        "0755"
end

execute "update-rc.d" do
  command "update-rc.d git-ultrasphinx defaults"
end

%w{install pack}.each do |action|  
  execute "bundle_#{action}" do
    cwd node[:gitorious][:app_base_dir]
    environment({ 'USER' => node['gitorious']['app_user'], 'HOME' => node['gitorious']['app_base_dir'] })
    command <<-CMD
    bash -c "source #{node['gitorious']['app_base_dir']}/.rvm/scripts/rvm && rvm #{node[:gitorious][:rvm_ruby_string]} && bundle #{action}"
    CMD
  end
end

%w{tmp/pids repositories tarballs}.each do |dir|
  directory "#{node[:gitorious][:app_base_dir]}/#{dir}" do
    owner node[:gitorious][:app_user]
    group node[:gitorious][:app_user]
  end
end

directory "#{node[:gitorious][:app_base_dir]}/.ssh" do
  owner node[:gitorious][:app_user]
  group node[:gitorious][:app_user]
  mode "0700"
end

file "#{node[:gitorious][:app_base_dir]}/.ssh/authorized_keys" do
  owner node[:gitorious][:app_user]
  group node[:gitorious][:app_user]
  mode "0600"
  action :touch
end

template "#{node[:gitorious][:app_base_dir]}/config/database.yml" do
  source      "database.yml.erb"
  owner node[:gitorious][:app_user]
  group node[:gitorious][:app_user]
  mode        "0640"
  variables(
    :rails_env    => node[:gitorious][:rails_env],
    :db_adapter   => node[:gitorious][:db][:type],
    :db_host      => node[:gitorious][:db][:host],
    :db_database  => node[:gitorious][:db][:database],
    :db_username  => node[:gitorious][:db][:user],
    :db_password  => node[:gitorious][:db][:password]
  )
end

template "#{node[:gitorious][:app_base_dir]}/config/gitorious.yml" do
  source      "gitorious.yml.erb"
  owner node[:gitorious][:app_user]
  group node[:gitorious][:app_user]
  mode        "0644"
  variables(
    :rails_env    => node[:gitorious][:rails_env]
  )
end

template "#{node[:gitorious][:app_base_dir]}/config/broker.yml" do
  source      "broker.yml.erb"
  owner node[:gitorious][:app_user]
  group node[:gitorious][:app_user]
  mode        "0644"
  variables(
    :rails_env    => node[:gitorious][:rails_env]
  )
end

if node[:gitorious][:db][:type] == "mysql"
  include_recipe "mysql::server"
  
  mysql_connection = {
    :host => node[:gitorious][:db][:host] || node[:mysql][:bind_address], 
    :username => node[:mysql][:root], 
    :password => node[:mysql][:server_root_password]
  }

  mysql_database node[:gitorious][:db][:database] do
    connection mysql_connection
    action :create
  end
    
  mysql_database_user node[:gitorious][:db][:user] do
    connection mysql_connection
    password node[:gitorious][:db][:password]
    database_name node[:gitorious][:db][:database]
    host node[:gitorious][:db][:host] || node[:mysql][:bind_address]
    action [ :create, :grant]
  end
elsif node[:gitorious][:db][:type] == "postgresql"
  include_recipe "postgresql::server"

  connection = {
    :host => node[:gitorious][:db][:host], 
    :username => node[:postgresql][:root],
    :password => node[:postgresql][:password][:postgres]
  }

  postgresql_database node[:gitorious][:db][:database] do
    connection connection
    action :create
  end
    
  postgresql_database_user node[:gitorious][:db][:user] do
    connection connection
    privileges ['ALL']
    password node[:gitorious][:db][:password]
    database_name node[:gitorious][:db][:database]
    host node[:gitorious][:db][:host]
    action [ :create, :grant]
  end
end

#fix activesupport...
cookbook_file "#{node[:gitorious][:app_base_dir]}/config/boot.rb" do
  source      "boot.rb"
  owner  node[:gitorious][:app_user]
  group node[:gitorious][:app_user]
  mode        "0644"
end

execute "migrate_gitorious_database_ultrasphinx" do
  cwd         node[:gitorious][:app_base_dir]
  user  node[:gitorious][:app_user]
  group node[:gitorious][:app_user]
  environment ({'RAILS_ENV' => node[:gitorious][:rails_env], 'USER' => node['gitorious']['app_user'], 'HOME' => node['gitorious']['app_base_dir']})
  command     <<-CMD
    bash -c "source #{node['gitorious']['app_base_dir']}/.rvm/scripts/rvm && rvm #{node[:gitorious][:rvm_ruby_string]} && bundle exec rake db:create" && \
    bash -c "source #{node['gitorious']['app_base_dir']}/.rvm/scripts/rvm && rvm #{node[:gitorious][:rvm_ruby_string]} && bundle exec rake db:migrate" && \
    bash -c "source #{node['gitorious']['app_base_dir']}/.rvm/scripts/rvm && rvm #{node[:gitorious][:rvm_ruby_string]} && bundle exec rake ultrasphinx:bootstrap"
  CMD
  if node[:gitorious][:db][:type] == "mysql"
    not_if do    
      m = Mysql.new(node[:gitorious][:db][:host] || node[:mysql][:bind_address], node[:mysql][:root], node[:mysql][:server_root_password])
      m.select_db node[:gitorious][:db][:database]
      m.list_tables.include? "schema_migrations"
    end
  elsif node[:gitorious][:db][:type] == "postgresql"
    
  end
end

cron "ultrasphinx" do
  command <<-CMD
    cd #{node[:gitorious][:app_base_dir]} && \
    bash -c "source #{node['gitorious']['app_base_dir']}/.rvm/scripts/rvm && rvm #{node[:gitorious][:rvm_ruby_string]} && bundle exec rake ultrasphinx:index RAILS_ENV=production && USER=#{node['gitorious']['app_user']} && HOME=#{node['gitorious']['app_base_dir']}"
  CMD
end

#fix spell bug
execute "add_ap_spell" do
  cwd   node[:gitorious][:app_base_dir]
  command <<-CMD
    cp vendor/plugins/ultrasphinx/examples/ap.multi /usr/lib/aspell/
    RAILS_ENV=#{node[:gitorious][:rails_env]} bash -c "source #{node['gitorious']['app_base_dir']}/.rvm/scripts/rvm && rvm #{node[:gitorious][:rvm_ruby_string]} && bundle exec rake ultrasphinx:spelling:build"
  CMD
  environment ({'RAILS_ENV' => node[:gitorious][:rails_env], 'USER' => node['gitorious']['app_user'], 'HOME' => node['gitorious']['app_base_dir']})
  not_if { File.exists?("/usr/lib/aspell/ap.multi") }
end

execute "create_gitorious_admin_user" do
  environment ({'RAILS_ENV' => node[:gitorious][:rails_env], 'USER' => node['gitorious']['app_user'], 'HOME' => node['gitorious']['app_base_dir']})
  cwd         node[:gitorious][:app_base_dir]
  user  node[:gitorious][:app_user]
  group node[:gitorious][:app_user]
  command     <<-CMD.sub(/^ {4}/, '')
    cat <<_INPUT | RAILS_ENV=#{node[:gitorious][:rails_env]} bash -c "source #{node['gitorious']['app_base_dir']}/.rvm/scripts/rvm && rvm #{node[:gitorious][:rvm_ruby_string]} && ruby script/create_admin #{node[:gitorious][:admin][:email]} #{node[:gitorious][:admin][:password]}"
    _INPUT
  CMD
  only_if     <<-ONLYIF
    cd #{node[:gitorious][:app_base_dir]} && \
    RAILS_ENV=#{node[:gitorious][:rails_env]} bash -c "source #{node['gitorious']['app_base_dir']}/.rvm/scripts/rvm && rvm #{node[:gitorious][:rvm_ruby_string]} && ruby script/runner 'User.find_by_is_admin(true) and abort'"
  ONLYIF
end

directory "#{node[:gitorious][:app_base_dir]}/certificates" do
  mode "700"
end

bash "Create SSL Certificates" do
  cwd "#{node[:gitorious][:app_base_dir]}/certificates"
  code <<-EOH
  umask 077
  openssl genrsa 2048 > gitorious-proxy.key
  openssl req -subj "#{node[:gitorious][:ssl_req]}" -new -x509 -nodes -sha1 -days 3650 -key gitorious-proxy.key > gitorious-proxy.crt
  cat gitorious-proxy.key gitorious-proxy.crt > gitorious-proxy.pem
  EOH
  not_if { ::File.exists?("#{node[:gitorious][:app_base_dir]}/certificates/gitorious-proxy.pem") }
end

template "/etc/nginx/sites-available/gitorious" do
  source "gitorious.erb"
end

nginx_site "gitorious"

%w{git-poller git-daemon gitorious}.each do |service| 
  runit_service service
end