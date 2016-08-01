require 'net/http'
require 'pry'

uri = URI('http://example.com/index.html')

def with_block(uri)
  Net::HTTP.start(uri.host, uri.port) do |http|
    my_get_request = Net::HTTP::Get.new uri
    server_response = http.request my_get_request
  end
end

# explanation
Net::HTTP.start #the HTTP.start method opens up a TCP/IP connection, just like a client does.

(uri.host, uri.port) #to do so, it calls on that host and port information

 do |http| #the block format is to keep using that same connection session for this bit of code

  my_get_request = Net::HTTP::Get.new uri # we're defining a GET request from that location

  server_response = http.request request # We're now making that specific request, and storing it in an HTTP response object
end


def no_block(uri)
  open_port = Net::HTTP.start(uri.host, uri.port)
  response = open_port.request(Net::HTTP::Get.new(uri))
  binding.pry
end

no_block(uri)
