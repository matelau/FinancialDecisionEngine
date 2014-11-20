require 'nokogiri'
require 'open-uri'
require 'json'
require 'pathname'

city_to_values = Hash.new 
# TODO update to collect data on multiple cities in a less formal matter
areas = ["salt+lake+city-ut", "phoenix-az", "san+francisco-ca", "new+york-ny"]

areas.each do |area|
	# Test Script used to play with nokogiri - pulls cost of living data from areavibes.com
	url = "http://www.areavibes.com//cost-of-living/"
	url.insert(25,area)
	puts "pulling data for: "+ url + "\n"
	data = Nokogiri::HTML(open(url))

	table =  data.css('table.std_facts.w')
	# map = table.children.map{|row| row.text.strip}
	# get headers index, city, state, national
	# city 
	city = table.css('th')[1].text

	columns = ["cost_of_living", "goods", "groceries", "health_care", "housing", "transportation", "utilities" ]

	values = Array.new
	# get values
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
# puts pwd
js = city_to_values.to_json
File.write(col_file, js)
# puts js
