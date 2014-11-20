require 'nokogiri'
require 'open-uri'

# Test Script used to play with nokogiri - pulls cost of living data from areavibes.com
url = "http://www.areavibes.com/salt+lake+city-ut/cost-of-living/"
data = Nokogiri::HTML(open(url))
puts data.at_css(".col_760").text.strip