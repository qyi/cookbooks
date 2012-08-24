
define :cloud9, :target => nil do
  include_recipe "cloud9"
  target = params[:target]

  execute "set permissions" do
    command <<-CMD
      setfacl -R -m u:#{node['cloud9']['user']}:rwx #{target}
      setfacl -dR -m u:#{node['cloud9']['user']}:rwx #{target}
    CMD
  end

  runit_service "cloud9-#{params[:name]}" do
    cookbook "cloud9"
    template_name "cloud9"
    options :target => target
  end
end