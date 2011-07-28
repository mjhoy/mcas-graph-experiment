require 'uri'
require 'net/http'

class GeoGet

  BASE_URL = "http://maps.googleapis.com/maps/api/geocode/json?sensor=false"

  class << self

    def geometry_for(address, label)
      @codes ||= {}
      return @codes[address] if @codes[address]
      puts '\n'
      puts '** Query: ' + label
      @codes[address] = _fetch(address)
    end

    def url_for(address)
      BASE_URL + "&address=" + URI.escape(address)
    end

    def _fetch(address)
      url = url_for(address)
      final = nil
      while !final
        res = send_request(url)
        if check_for_ok(res)
          final = ask(res)
          url = url_for(ask_for_new_address) unless final
        else
          url = url_for(ask_for_new_address)
        end
      end
      final
    end

    def send_request(url)
      res = Net::HTTP.get(URI.parse(url))
      JSON.parse(res)
    end

    def ask(res)
      choice = nil
      new_address = nil
      while !choice
        len = res["results"].length
        puts "Please choose:"
        res["results"].each_with_index do |addr, n|
          puts "#{n+1}. " + addr["formatted_address"]
        end
        puts "#{len+1}. Enter a new address for this entry"
        puts "---"

        a = gets.chomp
        unless (a.to_i.to_s != a)
          a = (a.to_i - 1)
          if a == len
            break
          end
          choice = res["results"][a] if check_maps(res["results"][a])
        end
      end
      choice
    end

    def check_maps(d)
      l = d["geometry"]["location"]
      ll = [l["lat"], l["lng"]].join(",")
      query = "?ll=#{ll}&z=9&q={ll}"
      %x{ open http://maps.google.com/#{query} }
      puts "Enter N if this is INCORRECT, else hit return."
      if gets =~ /^n/i
        false
      else
        true
      end
     end

    def ask_for_new_address
      puts "Please enter a new address:"
      gets.chomp
    end

    def check_for_ok(res)
      if res && res["results"] && res["results"][0] && res["results"][0]["geometry"]
        true
      else
        puts "Request no good:"
        p res
        false
      end
    end

  end

end
