

include_recipe "selenium"

if hub = search(:node, "selenium:hub").first
    node.set[:selenium][:hub][:domain] = hub[:ipaddress]
    node.save
end

runit_service "selenium-node" do
    run_restart false
end