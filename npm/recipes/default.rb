#
# Cookbook Name:: npm
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "nodejs"

package "npm" do
  action :install
  options "--force-yes"
end