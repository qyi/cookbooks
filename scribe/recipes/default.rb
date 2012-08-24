#
# Cookbook Name:: scribe
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "checkinstall"
include_recipe "python"
include_recipe "java"
include_recipe "ant"
include_recipe "git"
include_recipe "thrift"
include_recipe "thrift::fb303"

git "#{Chef::Config[:file_cache_path]}/scribe" do
  repository "git://github.com/facebook/scribe.git"
	action [ :sync, :checkout ]
end

directory "/var/log/scribe" do
  owner "root"
  group "root"
  mode "755"
end

directory "/usr/lib/hadoop" do 
  owner "root"
  group "root"
  mode "755"
  not_if { File.exists?("/usr/lib/hadoop") }
end

remote_file "#{Chef::Config[:file_cache_path]}/hadoop-0.20.2-cdh3u3.tar.gz" do
  source "http://archive.cloudera.com/cdh/3/hadoop-0.20.2-cdh3u3.tar.gz"
  only_if { node['scribe']['with-hdfs'] && !File.exists?("#{Chef::Config[:file_cache_path]}/hadoop-0.20.2-cdh3u3.tar.gz") }
  mode "755"
end

bash "tar" do
  cwd "#{Chef::Config[:file_cache_path]}"
  code <<-CMD
  tar -zxvf hadoop-0.20.2-cdh3u3.tar.gz
  cd hadoop-0.20.2-cdh3u3
  cp -r c++ src /usr/lib/hadoop
  CMD
  only_if { node['scribe']['with-hdfs'] && !File.exists?("/usr/lib/hadoop/c++") }
end

bash "install_scribe" do
  cwd "#{Chef::Config[:file_cache_path]}/scribe"
  code <<-CMD
  ./bootstrap.sh #{ "--enable-hdfs --with-hadooppath=/usr/lib/hadoop" if node['scribe']['with-hdfs'] }
  ./configure #{ "--enable-hdfs --with-hadooppath=/usr/lib/hadoop" if node['scribe']['with-hdfs'] }
  make 
  checkinstall --default --pakdir #{node[:checkinstall][:pakdir]} -D make install
  CMD
  if node['scribe']['with-hdfs']
    environment ({
      "CPPFLAGS" => "-I#{node[:java][:java_home]}/include -I#{node[:java][:java_home]}/include/linux -I/usr/lib/hadoop/src/c++/libhdfs",
      "LDFLAGS"  => "-L/usr/lib/hadoop/c++/Linux-#{node[:hadoop][:arch]}-#{node[:hadoop][:arch] =~ /i386/ ? '32' : '64'}/lib -L#{node[:java][:java_home]}/jre/lib/#{node[:hadoop][:arch]}/server"
    })
  end
  not_if { FileTest.exists?("/usr/local/bin/scribed") }
  action :run
end

directory "/usr/local/share/scribe" do
  owner "root"
  group "root"
  mode "755"
end

execute "to-share" do
  cwd "#{Chef::Config[:file_cache_path]}/scribe"
  command "cp if /usr/local/share/scribe -r"
  not_if { File.exists?("/usr/local/share/scribe/if") }
end

directory "/etc/scribe" do
  owner "root"
  group "root"
  mode "755"
end

template "/etc/scribe/scribe.conf" do  
  if node[:scribe][:central]
    source "central.conf.erb"
  else
    source "client.conf.erb"
  end
  owner "root"
  group "root"
  mode "755"
  variables(
    :hdfs => search(:node, 'recipes:hadoop\:\:namenode').first,
    :central => search(:node, 'recipes:scribe\:\:central').first
  )
end

runit_service "scribe"

scribe_php "/tmp"