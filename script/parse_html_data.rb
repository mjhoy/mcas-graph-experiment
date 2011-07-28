$: << File.join(File.dirname(__FILE__), '../lib')

require 'nokogiri'
require 'pp'
require 'json'
require 'getgeo'

JSON_FILE_OUTPUT = File.join(File.dirname(__FILE__), '../data/ma_district_geometry.json')

html = File.read(File.join(File.dirname(__FILE__), '../data/mcas_school_grade10_2010_all.html'))

doc = Nokogiri::HTML(html)
rows = doc.xpath('//table[@id="mcasGridView"]/tr')

# Get headers
headers = rows[0].xpath('th').map { |h| h.content }
pp headers

# Add denormalized data for a given MCAS data row `o`
def denormalize(o)
  matches = o["Org Name"].match(/(.*)\s-\s(.*)/)
  district = matches[1]
  school = matches[2]
  label = 
    "DISTRICT: " + district +
    ", SCHOOL: " + school
  address = school + ', Massachusetts'
  new = o.dup
  new["denorm"] ||= {}
  new["denorm"]["district"] = district
  new["denorm"]["school"] = school
  geom = GeoGet.geometry_for(address, label)
  new["denorm"]["geometry"] = {
    "lat" => geom["geometry"]["location"]["lat"],
    "lng" => geom["geometry"]["location"]["lng"]
  }
  new
end

if File.exist?(JSON_FILE_OUTPUT)
  data = JSON.parse(File.read(JSON_FILE_OUTPUT))
else
  data = []
end

rows[(data.length + 1)..-1].each do |r|
  o = {}
  r.xpath('td').each_with_index do |c, i| 
    h = headers[i]
    o[h] = c.content
  end
  o = denormalize(o)
  data.push o
  json = JSON.pretty_generate(data)
  File.open(JSON_FILE_OUTPUT, 'w+') { |f| f.write(json) }
  puts "Wrote file."
end
