
unless platform?("centos","redhat","fedora")
  include_recipe "runit::runit"
  include_recipe "runit::runit-man"
end
