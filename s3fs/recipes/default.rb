
include_recipe "build-essential"
include_recipe "checkinstall"

%w{ libfuse-dev fuse-utils libcurl4-openssl-dev libxml2-dev mime-support }.each do |pkg|
  package pkg
end

remote_file "#{Chef::Config[:file_cache_path]}/s3fs-#{node[:s3fs][:version]}.tar.gz" do
  source "http://s3fs.googlecode.com/files/s3fs-#{node[:s3fs][:version]}.tar.gz"
  mode 0644
  not_if { File.exists?("/usr/bin/s3fs") }
end

bash "install_s3fs" do
  cwd Chef::Config[:file_cache_path]
  code <<-CMD
  tar zxvf s3fs-#{node[:s3fs][:version]}.tar.gz
  cd s3fs-#{node[:s3fs][:version]}
  ./configure --prefix=/usr
  make
  checkinstall --default --pakdir #{node[:checkinstall][:pakdir]} -D make install
  CMD
  not_if { File.exists?("/usr/bin/s3fs") }
end

template "/etc/passwd-s3fs" do
  owner "root"
  group "root"
  mode "600"
  variables( :buckets => search(:s3, "*:*"))
end

search(:s3, "*:*").each do |bucket|
  directory "/mnt/#{ bucket[:id] }" do
    owner "root"
    group "root"
    mode "755"
  end
  
  bash "mount_#{bucket[:id]}" do
    code <<-CMD    
    s3fs #{ bucket[:id] }  -o allow_other /mnt/#{ bucket[:id] } 
    CMD
    not_if "mount -l | grep /mnt/#{ bucket[:id] }"
  end

end