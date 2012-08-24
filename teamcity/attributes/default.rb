#
# Cookbook Name:: TeamCity
# Attributes:: teamcity
#
# Copyright 2008-2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['teamcity']['virtual_host_name']  = "t.#{ node['assigned_fqdn'] || node['fqdn']}"
default['teamcity']['virtual_host_alias'] = "teamcity.#{ node['assigned_fqdn'] || node['fqdn']}"
default['teamcity']['port']		    = 8111

default['teamcity']['version']              = "7.0"
default['teamcity']['install_path']         = "/var/www/tools/teamcity"
default['teamcity']['home_path']	        = "/var/www/tools/home/teamcity"
default['teamcity']['run_user']             = "teamcity"
default['teamcity']['database']['type']     = "postgresql"
default['teamcity']['database']['host']     = "127.0.0.1"
default['teamcity']['database']['port']     = "5432"
default['teamcity']['database']['user']     = "teamcitydbuser"
default['teamcity']['database']['name']     = "teamcitydb"
default['teamcity']['database']['host']     = "127.0.0.1"

default['teamcity']['build_dir']                = "/var/www/builds"
default['teamcity']['server']['backup']         = true
default['teamcity']['server']['log']['scribe']  = true

default['teamcity']['agent']['servers'] = []
default['teamcity']['agent']['name']    = node.name
default['teamcity']['agent']['dir']     = "/agents"
default['teamcity']['agent']['port']	= "9090"
default['teamcity']['agent']['database']['name'] = 'test'
default['teamcity']['agent']['database']['user'] = 'test'
default['teamcity']['agent']['user'] = 'tagent'
default['teamcity']['agent']['group'] = 'tagent'


