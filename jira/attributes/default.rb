#
# Cookbook Name:: jira
# Attributes:: jira
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

default[:jira][:virtual_host_name]  = "j.#{ node[:assigned_fqdn] || node[:fqdn]}"
default[:jira][:virtual_host_alias] = "jira.#{ node[:assigned_fqdn] || node[:fqdn]}"
default[:jira][:port]		    = 8080
# type-version-standalone
default[:jira][:version]           = "5.0.3"
default[:jira][:install_path]      = "/var/www/tools/jira"
default[:jira][:home_path]	   = "/var/www/tools/home/jira"
default[:jira][:run_user]          = "jira"
default[:jira][:database][:type]   = "postgresql"
default[:jira][:database][:host]   = "127.0.0.1"
default[:jira][:database][:port]   = "5432"
default[:jira][:database][:user]   = "jiradbuser"
default[:jira][:database][:name]   = "jiradb"

default['jira']['memory']['min']   = "256m"	
default['jira']['memory']['max']   = "256m"
default['jira']['plugins_load_timeout'] = 300

default[:jira][:backup]	= true
default[:jira][:log][:scribe] = true

