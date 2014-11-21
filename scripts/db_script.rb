require 'mysql2'

db_client = Mysql2::Client.new(
  :host => "#{host_ip}", 
  :username => "#{username}",
  :password => "#{password}",
  :database => "#{database_name}")

query = "SELECT col_name FROM table"
results = db_client.query(query)