require 'uri'
require 'net/http'

(2005..2010).each do |y|
  file = File.join(File.dirname(__FILE__), '../data/html/g10_' + (y.to_s) +'_all.html')
  url = "http://profiles.doe.mass.edu/state_report/mcas.aspx?&reportType=SCHOOL&grade=10&apply2006=Y&year=#{y.to_s}&studentGroup=AL:AL"
  res = Net::HTTP.get(URI.parse(url))
  File.open(file, 'w+') { |f| f.write(res) }
end
