$: << File.join(File.dirname(__FILE__), '../lib')

require 'nokogiri'
require 'pp'
require 'json'
require 'getgeo'

JSON_FILE_OUTPUT = File.join(File.dirname(__FILE__), '../data/ma_district_geometry.json')
DENORM_FILE = File.join(File.dirname(__FILE__), '../data/denorm.json')

HTML_FILES = (2005..2010).map do |year|
  File.join(File.dirname(__FILE__), '../data/html/g10_' + (year.to_s) +'_all.html')
end

@denorm = JSON.parse File.read(DENORM_FILE)

tables = {}
HTML_FILES.each do |filename|
  html = File.read(filename)

  doc = Nokogiri::HTML(html)
  rows = doc.xpath('//table[@id="mcasGridView"]/tr')
  tables[filename] = rows
end

# Add denormalized data for a given MCAS data row `o`
def denormalize(o)
  return o if o["denorm"]
  if @denorm[o["Org Code"]]
    new = o.dup
    new["denorm"] = @denorm[o["Org Code"]]
    return new
  else
    # Not going to deal with older addresses not in 2010
    # for now.
    return o
  end
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
  @denorm[o["Org Name"]] = new["denorm"]
  new
end

save = 0
tables.each do |filename, rows|
  file_out = filename.sub(/html$/, 'json')
  if File.exist?(file_out)
    data = JSON.parse(File.read(file_out))
  else
    data = []
  end
  data = []
  headers = rows[0].xpath('th').map(){|h|h.content}
  rows[(data.length + 1)..-1].each do |r|
    o = {}
    r.xpath('td').each_with_index do |c, i| 
      h = headers[i]
      o[h] = c.content
    end
    o = denormalize(o)
    data.push o
    save += 1
    if r == rows[-1]
      json = JSON.pretty_generate(data)
      File.open(file_out, 'w+') { |f| f.write(json) }
      puts "Wrote file."
      File.open(DENORM_FILE, 'w+') { |f| f.write(JSON.pretty_generate(@denorm)) }
      puts "Wrote denorm."
    end
  end
end
