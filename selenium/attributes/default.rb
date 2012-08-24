

default['selenium']['version']		= "2.23.1"
default['selenium']['install_path']	= "/usr/lib/selenium"

default['selenium']['hub']['domain']	= "localhost"
default['selenium']['hub']['port']		= 4444

default['selenium']['driver']['chrome']['version'] = "20.0.1133.0"
default['selenium']['driver']['chrome']['source'] = "http://chromedriver.googlecode.com/files/chromedriver_linux#{kernel['machine'] =~ /x86_64/ ? "64" : "32"}_#{node['selenium']['driver']['chrome']['version']}.zip"