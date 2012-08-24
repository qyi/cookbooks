#
# Cookbook Name:: phantomjs
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "phantomjs::#{node['phantomjs']['install_method']}"

if `echo $DISPLAY`.strip.empty?
  package "xvfb"
    
  cookbook_file "/etc/init.d/Xvfb" do
    source "Xvfb.init"
    owner "root"
    group "root"
    mode "0755"
  end

  service "Xvfb" do
    supports [:status, :restart ]
    action [:enable, :start]   
  end
end
