define :scribe_php do
  bash "compile_php_client" do
    cwd params[:name]
    code <<-CMD
    thrift -o . -I /usr/local/share/ --gen php /usr/local/share/fb303/if/fb303.thrift 
    thrift -o . -I /usr/local/share/ --gen php /usr/local/share/scribe/if/scribe.thrift
    cp /usr/local/share/thrift/lib/php/src includes -r   
    mkdir -p includes/packages/fb303
    mkdir -p includes/packages/scribe
    mv gen-php/fb303/FacebookService.php gen-php/fb303/fb303_types.php includes/packages/fb303/
    mv gen-php/scribe/scribe_types.php includes/packages/scribe/
    mv gen-php/scribe/scribe.php includes/          
    rm -rf gen-php       
    CMD
  end
end