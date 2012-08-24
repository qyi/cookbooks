
package "libfontconfig-dev"

remote_file "#{Chef::Config['file_cache_path']}/phantomjs.tar.gz" do
  source node['phantomjs']['tarball']['url']
  not_if { File.exists? "#{Chef::Config['file_cache_path']}/phantomjs.tar.gz" }
  not_if "which phantomjs && [[ `phantomjs --version` == \"#{node['phantomjs']['version']}\" ]]"
end

bash "extract #{Chef::Config['file_cache_path']}/phantomjs.tar.gz, move it to /usr/local/phantomjs" do
  user "root"
  cwd  Chef::Config['file_cache_path']

  code <<-EOS
    rm -rf /usr/local/phantomjs
    tar -zxvf #{Chef::Config['file_cache_path']}/phantomjs.tar.gz
    mv --force #{Chef::Config['file_cache_path']}/phantomjs /usr/local/phantomjs
  EOS

  creates "/usr/local/phantomjs/bin/phantomjs"
end

#link "/usr/local/bin/phantomjs" do
#  owner "root"
#  group "root"
#  to    "/usr/local/phantomjs/bin/phantomjs"
#end