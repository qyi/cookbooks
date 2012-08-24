

include_recipe "selenium"

runit_service "selenium-hub" do
    run_restart false
end

remote_file "#{Chef::Config[:file_cache_path]}/chromedriver.zip" do
  source node['selenium']['driver']['chrome']['source']
  not_if { File.exists? "#{Chef::Config[:file_cache_path]}/chromedriver.zip" }
end

execute "unzip chromedriver" do
  cwd "/usr/local/bin"
  command "unzip #{Chef::Config[:file_cache_path]}/chromedriver.zip"
  not_if { File.exists? "/usr/local/bin/chromedriver" }
end