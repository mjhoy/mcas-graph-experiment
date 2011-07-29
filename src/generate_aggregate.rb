# This script takes a JSON file of the form:
#
# [
#   {
#     "Org Name"...
#     "Org Code"...
#     "Subject": "ELA"
#     "P+/A %"...
#     ...
#   }
# ]
#
# And combines entries on "Org Code", moving statistical data
# to a subject key, like so:
#
# [
#   {
#     "Org Name" ..
#     "Org Code" ..
#     "ELA": {
#       "P+/A %" ..
#       ...
#     }
#     "MTH" ...
#   }
# ]
#
# and so on.

require 'json'
require 'pp'

file = File.read(ARGV[0])
file_to_write = ARGV[1]
data = JSON.parse(file)

raise "Couldn't parse file" unless data

codes = { }
general_keys = [ "Org Name", "Org Code", "denorm" ]

data.each do |d|
  code = d["Org Code"]
  subj = d["Subject"]

  unless codes[code]
    o = { }; general_keys.each { |k| o[k] = d[k] }
    codes[code] = o
  end

  s = { }
  d.keys.reject {|k| general_keys.include? k}.each do |k|
    s[k] = d[k]
  end
  codes[code][subj] = s
end

arr = codes.map { |k, v| v }
if file_to_write
  File.open(file_to_write, 'w+') { |f| f.write(JSON.pretty_generate(arr)) }
else
  puts JSON.pretty_generate(arr)
end
