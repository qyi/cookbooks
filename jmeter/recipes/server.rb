# Cookbook Name:: ant
#
# Recipe:: default
#
# Copyright 2010, Opscode, Inc.
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
require 'chef/mixin/shell_out'

package "acl"

ruby_block "reload_client_config" do
  block do
    config = Array.new
    mount = Array.new
    File.open('/etc/fstab').each_line{ |line|
      args = line.split(" ")
      if args.length == 6
        if args.first.start_with?("UUID") && !args[3].include?("acl")
          args[3] << ",acl"
          line = args.join("  ") + "\n"
          mount << args[1]
        elsif args[3].include?("acl")
          mount << args[1]
        end
      end
      config << line
    }
    File.open('/etc/fstab', 'w') { |fstab| fstab.write config.join("") }
    opts = { "timeout" => 3600 }
    mount.each do |path|
      # TODO: make throw shell_out
      #shell_out!("sudo mount -o remount #{path}", opts)
      `sudo mount -o remount #{path}`
      Chef::Log.info("remount #{path} ran successfully")
    end
  end
  action :create
  not_if "mount | grep acl"
end