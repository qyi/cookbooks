define :scribe_log4j, :lang => false do
  include_recipe "maven"
  include_recipe "mercurial"

  bash "download" do
    cwd Chef::Config[:file_cache_path]
    code <<-CMD
    hg clone https://scribe-log4j.googlecode.com/hg/ scribe-log4j
    CMD
    not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/scribe-log4j") }
  end

  bash "compile_scribe_client" do
    cwd "#{Chef::Config[:file_cache_path]}/scribe-log4j/scribe-client"
    code "mvn install"
    not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/scribe-log4j/scribe-client/target") }
  end

  bash "compile_log4j_client" do
    cwd "#{Chef::Config[:file_cache_path]}/scribe-log4j/scribe-log4j"
    code "mvn install"
    not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/scribe-log4j/scribe-log4j/target") }
  end

  bash "copy log4j #{params[:name]}" do
    cwd "#{Chef::Config[:file_cache_path]}/scribe-log4j"
    code <<-CMD
    cp scribe-client/target/scribe-client-1.0.jar #{params[:name]}
    cp scribe-log4j/target/scribe-log4j-1.0.jar #{params[:name]}
    CMD
    not_if { ::File.exists?("#{params[:name]}/scribe-client-1.0.jar") && ::File.exists?("#{params[:name]}/scribe-log4j-1.0.jar") }
  end
  
  remote_file "#{Chef::Config[:file_cache_path]}/commons-lang-2.5-bin.tar.gz" do
    source "http://www.sai.msu.su/apache//commons/lang/binaries/commons-lang-2.5-bin.tar.gz"
    not_if { ::File.exists? "#{Chef::Config[:file_cache_path]}/commons-lang-2.5-bin.tar.gz" }
  end
  
  bash "copy commons lang #{params[:name]}" do
    cwd Chef::Config[:file_cache_path]
    code <<-CMD
    tar -zxvf commons-lang-2.5-bin.tar.gz
    cp commons-lang-2.5/commons-lang-2.5.jar #{params[:name]}
    CMD
    not_if { ::File.exists? "#{params[:name]}/commons-lang-2.5.jar" }
    only_if { params[:lang] }
  end
    
end