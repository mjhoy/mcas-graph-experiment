require 'json'


data = JSON.parse File.read(File.join(File.dirname(__FILE__), '../data/mcas_agg.json'))
geo = {}
data.each do |d|
  geo[d["Org Code"]] = d["denorm"]
end

File.open(File.join(File.dirname(__FILE__), '../data/denorm.json'), 'w+') do |f|
  f.write JSON.pretty_generate(geo)
end
