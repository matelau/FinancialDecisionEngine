require 'nokogiri'
require 'open-uri'
require 'json'
require 'pathname'
require 'mysql2'
require 'yaml'

loc_to_values = Hash.new 
state_to_values = Hash.new
# TODO update to collect data on multiple cities in a less formal matter
# areas = ["phoenix-az", "tucson-az", "mesa-az", "los+angeles-ca", "san+francisco-ca", "san+jose-ca", "san+diego-ca", "sacramento-ca", "denver-co", "colorado+springs-co", "aurora-co", "fort+lauderdale-fl", "jacksonville-fl", "miami-fl", "tampa-fl", "new+york-ny", "oyster+bay-ny", "buffalo-ny", "austin-tx", "houston-tx", "san+antonio-tx", "dallas-tx", "seattle-wa", "spokane-wa", "tacoma-wa", "vancouver-wa", "madison-wi", "milwaukee-wi", "green+bay-wi", "salt+lake+city-ut", "west+valley+city-ut", "provo-ut"]
 
areas = ["phoenix-az"]
columns = Array.new
areas.each do |area|
	# Test Script used to play with nokogiri - pulls cost of living data from areavibes.com
	url = "http://www.areavibes.com//cost-of-living/"
	url.insert(25,area)
	puts "pulling data for: "+ url + "\n"
	data = nil
	begin
		data = Nokogiri::HTML(open(url))
	rescue OpenURI::HTTPError => e
		log_file = Pathname.pwd.to_s + "/data/error_logs"
		error_message = DateTime.now.to_s + " Cost_of_living_scraper.rb area: "+ area + " error: "+ e.message.to_s
		File.write(log_file, error_message)
		# continue
		next
	end

	table =  data.css('table.std_facts.w')
	#headers =  index, city, state, national
	state = table.css('th')[2].text
	city = table.css('th')[1].text

	columns = ["cost_of_living", "goods", "groceries", "health_care", "housing", "transportation", "utilities" ]

	values = Array.new
	state_values = Array.new
	#tds = column title, city val, state val, national val
	table.css('tr').each do |row|
		str = row.css('td')[1]
		str2 = row.css('td')[2]
		# check for nil
		if str.to_s == "" 
			# do nothing
		else
			# remove html tags
			values.push str.text.strip
			state_values.push str2.text.strip
		end
	end

	# TODO research map! and flatten to map vals
	# map city vals to columns
	columns_to_values = Hash.new
	columns.each_with_index do |col , x|
		columns_to_values[col] = values[x]
	end
	# include general state col in data
	# columns_to_values[state] = state_values[0]
	loc_to_values[city] = columns_to_values 


	if state_to_values.key?(state)
		# do nothing
	else
		# map state vals to columns	
		columns_to_values = Hash.new
		columns.each_with_index do |col, x|
			columns_to_values[col] = state_values[x]
		end
		loc_to_values[state] = columns_to_values
	end

end
store_vals = Hash.new
table_name = "colis"
store_vals[table_name] = loc_to_values
curr_loc = " "
col = " "
goods = " "
groc = " "
hc = " "
housing = " "
trans = " "
util = " "

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
  :database => "#{@database_name}",
  :secure_auth => false)

store_vals[table_name].each do |loc|
	curr_loc =  loc[0].to_s
	loc_data =loc_to_values[curr_loc]
	col = loc_data[columns[0]]
	goods = loc_data[columns[1]]
	groc = loc_data[columns[2]]
	hc = loc_data[columns[3]]
	housing = loc_data[columns[4]]
	trans = loc_data[columns[5]]
	util = loc_data[columns[6]]
	query = "INSERT INTO cents_dev.colis (cost_of_living, transportation, groceries, goods, health_care, utilities, location, housing) VALUES (#{col},#{trans},#{groc},#{goods},#{hc},#{housing},#{util}, #{curr_loc}, #{housing})"
	puts query
	results =  db_client.query(query)
	puts results
end


store_vals
col_file = Pathname.pwd.to_s + "/data/col.json"
# col_state_file = Pathname.pwd.to_s + "/data/col_state.json"
js = store_vals.to_json
File.write(col_file, js)
# js = state_to_values.to_json
# File.write(col_state_file, js)


# TODO implement logic to store values to db