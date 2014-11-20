require 'nokogiri'
require 'open-uri'
require 'json'
require 'pathname'

city_to_values = Hash.new 
state_to_values = Hash.new
# TODO update to collect data on multiple cities in a less formal matter
areas = ["phoenix-az", "tucson-az", "los+angeles-ca", "san+francisco-ca", "san+jose-ca", "sacramento-ca", "denver-co", "fort+lauderdale-fl", "new+york-ny", "austin-tx", "seattle-wa", "madison-wi", "salt+lake+city-ut"]

areas.each do |area|
	# Test Script used to play with nokogiri - pulls cost of living data from areavibes.com
	url = "http://www.areavibes.com//cost-of-living/"
	url.insert(25,area)
	puts "pulling data for: "+ url + "\n"
	data = Nokogiri::HTML(open(url))

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

	# map city vals to columns
	columns_to_values = Hash.new
	columns.each_with_index do |col , x|
		columns_to_values[col] = values[x]
	end
	# include general state col in data
	columns_to_values[state] = state_values[0]
	city_to_values[city] = columns_to_values 


	if state_to_values.has_key?(state)
		# do nothing
	else
		columns_to_values = Hash.new
		columns.each_with_index do |col, x|
			columns_to_values[col] = state_values[x]
		end
		state_to_values[state] = columns_to_values
	end
	# map state vals to columns	
end
col_file = Pathname.pwd.to_s + "/data/col.json"
col_state_file = Pathname.pwd.to_s + "/data/col_state.json"
js = city_to_values.to_json
File.write(col_file, js)
js = state_to_values.to_json
File.write(col_state_file, js)


# TODO implement logic to store values to db