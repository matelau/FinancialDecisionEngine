require 'mysql2'
require 'yaml'
require 'pathname'

# get relative path
path = Pathname.pwd.to_s
path.sub! 'scripts', 'config/database.yml'
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

# TODO pull table name from file

# query = "SELECT col_name FROM table"

# INSERT INTO cents_dev.colis (cost_of_living, transportation, groceries, goods, health_care, utilities, location)  VALUES (1.0,2.0,3.0,4.0,5.0,6.0,"Test Location");
# results = db_client.query(query)