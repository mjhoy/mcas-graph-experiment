require 'json'
require 'pp'

collected = {}
GENERAL = ["Org Code", "Org Name", "denorm"]

Dir[File.join(File.dirname(__FILE__), '../data/html/') + '*.json'].each do |file|
  year = file.match(/_(\d{4})_/)[1]
  raise unless year
  json = JSON.parse(File.read(file))
  json.each do |d|
    unless collected[d["Org Code"]]
      collected[d["Org Code"]] = d.reject {|k,v| !GENERAL.include?(k)}
    end
    collected[d["Org Code"]][year] ||= {}
    collected[d["Org Code"]][year][d["Subject"]] = d.reject {|k,v| GENERAL.include?(k) }
  end
end

out = File.join(File.dirname(__FILE__), '../data/g10_all.json')
c = collected.map(){|k,v|v}
File.open(out, 'w+') { |f| f.write(c.to_json) }
