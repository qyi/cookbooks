default['phantomjs']['install_method'] = "tarball"
default['phantomjs']['version'] = "1.5.0"
default['phantomjs']['tarball']['url'] = "http://phantomjs.googlecode.com/files/phantomjs-#{node['phantomjs']['version']}-linux-#{kernel['machine'] =~ /x86_64/ ? "x86_64" : "x86"}-dynamic.tar.gz"

default[:phantomjs][:install_path] = "/opt/phantomjs"
