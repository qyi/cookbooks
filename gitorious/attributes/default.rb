default[:gitorious][:git][:url] = "git://gitorious.org/gitorious/mainline.git"
default[:gitorious][:git][:reference] = "master"

default[:gitorious][:web_server] = "nginx"
default[:gitorious][:virtual_host_name]  = "g.#{ node[:assigned_fqdn] || node[:fqdn]}".downcase
default[:gitorious][:virtual_host_alias] = "clone.#{ node[:assigned_fqdn] || node[:fqdn]}".downcase
default[:gitorious][:port]               = "3001"

default[:gitorious][:init_style] = "runit"

default[:gitorious][:use_ssl]	  = false
default[:gitorious][:ssl][:cert]  = "ssl-cert-snakeoil.pem"
default[:gitorious][:ssl][:key]   = "ssl-cert-snakeoil.key"
default[:gitorious][:ssl_req]  	  = "/C=US/ST=Several/L=Locality/O=Example/OU=Operations/CN=git.#{ node[:assigned_fqdn] || node[:fqdn] }/emailAddress=root@localhost"

default[:gitorious][:app_user]      = "git"
default[:gitorious][:app_base_dir]  = "/var/www/tools/gitorious"
default[:gitorious][:git_base_dir]  = "/var/www/tools/gitorious" #git
default[:gitorious][:rails_env]     = "production"

default[:gitorious][:rvm_ruby]      = "ruby-1.8.7-p334"
default[:gitorious][:rvm_gemset]    = "global"
default[:gitorious][:rvm_ruby_string] = "#{node[:gitorious][:rvm_ruby]}@#{node[:gitorious][:rvm_gemset]}"

default[:gitorious][:db][:type]		= "mysql"
default[:gitorious][:db][:host]     = node[:ipaddress]
default[:gitorious][:db][:port]		= "3306"
default[:gitorious][:db][:database] = "gitorious"
default[:gitorious][:db][:user]     = "gitor"

default[:gitorious][:host]                = "g.#{ node[:assigned_fqdn] || node[:fqdn]}".downcase
default[:gitorious][:clone_host]		  = "clone.#{ node[:assigned_fqdn] || node[:fqdn] }".downcase
default[:gitorious][:support_email]       = "support@whysofast.ru"
default[:gitorious][:notification_emails] = "su2ny@mail.ru"
default[:gitorious][:public_mode]         = "false"
default[:gitorious][:only_admins_create]  = "true"
default[:gitorious][:cookie_secret]		  = "ujmonVicEpjashrinlatIcjijwatijrajErvAfimErvInyudibVocjutcusyewoajavRihawoyThijCeseicinGamnokepVojVasVodsIakvumDavVagoskEsVeadtellenfewmitilyoWrykOgTibGeenyechokganrawlEtNuOdVarab4dryWrashdelt2yeysodyowadvagsugEnbirvyuckVe=quafIkMybroypiakVakyerfOftAmFawCengarUrgIrEpWowgUjVokvamRelWodMuotMoisAkTevFeywe7droTenkyandyejuj[wicFeotiperWoDreituc8FrajLuFrakObVouWygalakganQuiutheivjodnewJan"

default[:gitorious][:admin][:email]       = "admin@gitorious.local"
default[:gitorious][:admin][:password]    = "admin"

default[:gitorious][:locale]               = "en"
default[:gitorious][:hide_http_clone_urls] = "true"

default[:gitorious][:optional_tls][:url] =
  "git://github.com/collectiveidea/action_mailer_optional_tls.git"

default[:gitorious][:mailer][:delivery_method]  = "smtp"

default[:gitorious][:smtp][:tls]            = "false"
default[:gitorious][:smtp][:address]        = "smtp.example.com"
default[:gitorious][:smtp][:port]           = ""
default[:gitorious][:smtp][:domain]         = ""
default[:gitorious][:smtp][:authentication] = "plain"
default[:gitorious][:smtp][:username]       = ""
default[:gitorious][:smtp][:password]       = ""

default[:git][:home] 	= node[:gitorious][:app_base_dir]
default[:git][:user] 	= node[:gitorious][:app_user]

default[:gitorious][:backup] = true