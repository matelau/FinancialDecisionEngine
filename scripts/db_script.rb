# require 'mysql2'
require 'yaml'
require 'pathname'

path = Pathname.pwd.to_s
path.sub! 'scripts', 'config/database.yml'
puts path
db_vals = YAML.load_file(path)
values = db_vals["development"]
@host_ip = values["host"]
@port = values["port"]
@username = values["username"]
@password = values["password"]
@database_name = values["database"]

db_client = Mysql2::Client.new(
  :host => "#{@host_ip}", 
  :port => "#{@port}",
  :username => "#{@username}",
  :password => "#{@password}",
  :database => "#{@database_name}")

# query = "SELECT col_name FROM table"
# results = db_client.query(query)