require 'nokogiri'
require 'open-uri'
require 'json'
require 'pathname'
require 'mysql2'
require 'yaml'

areas = ["phoenix-az"] #,  "tucson-az", "mesa-az", "los+angeles-ca", "san+francisco-ca", "san+jose-ca", "san+diego-ca", "sacramento-ca", "denver-co", "colorado+springs-co", "aurora-co", "fort+lauderdale-fl", "jacksonville-fl", "miami-fl", "tampa-fl", "new+york-ny", "oyster+bay-ny", "buffalo-ny", "austin-tx", "houston-tx", "san+antonio-tx", "dallas-tx", "seattle-wa", "spokane-wa", "tacoma-wa", "vancouver-wa", "madison-wi", "milwaukee-wi", "green+bay-wi", "salt+lake+city-ut", "west+valley+city-ut", "provo-ut"]
weather_area = Hash.new
#------------------------- weather data ------------------------------
areas.each do |area|
	# Test Script used to play with nokogiri - pulls cost of living data from areavibes.com
	url = "http://www.areavibes.com//weather/"
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

	month_data = Hash.new
	table =  data.css('table.std_facts.w')

	columns = ["min","max","avg"] #,"precip"]
	
	count = 0
	#tds = month, min, max, avg, precip
	table.css('tr').each do |row|
		month = row.css('td')[0]
		min = row.css('td')[1]
		max = row.css('td')[2]
		avg = row.css('td')[3]
		precip = row.css('td')[4]

		# check for nil 
		if month.nil? || min.nil? || max.nil? || avg.nil? || precip.nil?
			# do nothing
			# puts "do nothing block"
		elsif count > 11
			# ignore air qual and pollution index
			# puts "overcount"		
		else
			values = Array.new
			# remove html tags
			month = month.text.strip
			values.push min.text.strip.slice 0..-3
			values.push max.text.strip.slice 0..-3
			values.push avg.text.strip.slice 0..-3
			# values.push precip.text.strip.slice 0..-2

			columns_to_values = Hash.new
			columns.each_with_index do |col , x|
				columns_to_values[col] = values[x]
			end

			# puts columns_to_values
			month_data[month] = columns_to_values
			count = count + 1
		end
	end

	weather_area[area] = month_data
end

# query = SELECT id FROM cents_dev.colis WHERE location="Washington";