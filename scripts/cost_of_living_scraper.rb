require 'nokogiri'
require 'open-uri'
require 'json'
require 'pathname'

city_to_values = Hash.new 
# TODO update to collect data on multiple cities in a less formal matter
areas = ["phoenix-az", "tucson-az", "san+francisco-ca", "san+jose-ca", "sacramento-ca", "denver-co", "fort+lauderdale-fl", "new+york-ny", "austin-tx", "salt+lake+city-ut"]

areas.each do |area|
	# Test Script used to play with nokogiri - pulls cost of living data from areavibes.com
	url = "http://www.areavibes.com//cost-of-living/"
	url.insert(25,area)
	puts "pulling data for: "+ url + "\n"
	data = Nokogiri::HTML(open(url))

	table =  data.css('table.std_facts.w')
	#headers =  index, city, state, national
	city = table.css('th')[1].text

	columns = ["cost_of_living", "goods", "groceries", "health_care", "housing", "transportation", "utilities" ]

	values = Array.new
	#tds = column title, city val, state val, national val
	table.css('tr').each do |row|
		str = row.css('td')[1]
		# check for nil
		if str.to_s == ""
			# do nothing
		else
			values.push str.text.strip
		end
	end

	columns_to_values = Hash.new
	columns.each_with_index do |col , x|
		columns_to_values[col] = values[x]
	end

	city_to_values[city] = columns_to_values 
	
end
col_file = Pathname.pwd.to_s + "/data/col.json"
js = city_to_values.to_json
File.write(col_file, js)


# TODO implement logic to store values to db