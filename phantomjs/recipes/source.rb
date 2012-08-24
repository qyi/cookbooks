#
# Cookbook Name:: phantomjs
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "git"

package "libqt4-dev"
package "libqtwebkit-dev"
package "qt4-qmake"

unless File.exists?("/usr/bin/phantomjs")
    git "/tmp/phantomjs" do
        repository "git://github.com/ariya/phantomjs.git"
        revision "#{node[:phantomjs][:version]}"
        action [ :sync, :checkout ]
    end

    bash "make" do
        code "qmake-qt4 && make && cp /tmp/phantomjs/bin/phantomjs /usr/bin"
        cwd "/tmp/phantomjs"
    end
end

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
