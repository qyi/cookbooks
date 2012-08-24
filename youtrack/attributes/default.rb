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

default['youtrack']['virtual_host_name']  = "y.#{ node['assigned_fqdn'] || node['fqdn']}"
default['youtrack']['virtual_host_alias'] = "youtrack.#{ node['assigned_fqdn'] || node['fqdn']}"
default['youtrack']['port']		    = 8112

default['youtrack']['version']              = "4.0"
default['youtrack']['install_path']         = "/var/www/tools/youtrack"