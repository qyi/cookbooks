#
# Cookbook Name:: nodejs
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "build-essential"
include_recipe "checkinstall"
include_recipe "git"
include_recipe "openssl"

%w{ curl libssl-dev }.each do |install|
    package install
end

unless File.exists?("/usr/local/bin/node") || File.exists?("/usr/bin/node")
    git "Fetch NodeJs" do                            
      repository "https://github.com/joyent/node.git"                                   
      action :sync                                     
      destination "#{Chef::Config[:file_cache_path]}/node"
      reference node['nodejs']['version']
    end

    bash "install-nodejs" do
      cwd "#{Chef::Config[:file_cache_path]}/node"
      code <<-EOH
        ./configure
        make && sudo checkinstall --default -D make install
      EOH
    end
end