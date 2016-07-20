require 'net/http'
require 'pry'

uri = URI('http://example.com/index.html')

def with_block(uri)
  Net::HTTP.start(uri.host, uri.port) do |http|
    my_get_request = Net::HTTP::Get.new uri
    server_response = http.request my_get_request
  end
end

# with_block(uri)


def no_block(uri)
  open_port = Net::HTTP.start(uri.host, uri.port)
  response = open_port.request(Net::HTTP::Get.new(uri))
  binding.pry
end

no_block(uri)
