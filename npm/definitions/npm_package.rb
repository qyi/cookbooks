define :npm_package, :action => "install", :global => true do
  include_recipe "npm"

  bash "install_#{params[:name]}" do
  	code <<-CMD
  	npm install #{params[:name]} #{ "-g" if params[:global] }
  	CMD
    not_if "which #{params[:name]}"
  end
end