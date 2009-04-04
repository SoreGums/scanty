configure do
  require 'ostruct'
  Blog = OpenStruct.new(
    :title => 'a name for your blog',
    :author => 'Joel Tulloch',
    :url_base => 'http://localhost:4567/',
    :ping_services => 'ping.xml',  #relative to /config
    :log_folder => 'logs', #will be placed in the application root		
    :admin_password => 'changethis',
    :admin_cookie_key => 'admin_cookie_key',
    :admin_cookie_value => '54l976913ace58',
    :disqus_shortname => nil
  )
  # Makura::Model.server = 'http://localhost:5984'
  Makura::Model.database = 'change_db_name'
end