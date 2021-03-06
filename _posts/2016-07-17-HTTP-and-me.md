---
layout: post
title: HTTP and me
---

I've found myself wondering about how we talk to the internet, and how I do it through intermediaries like Sinatra — because, right now, it really looks like magic. Magic is cool, but it's hard to talk about, so hopefully breaking it down helps!

<img src="http://www.antipope.org/charlie/old/attic/webbook/gif/fig3-2.gif">

As a refresher, Hypertext Transfer Protocol regulates how we access stuff on the internet -- specifically interactions between clients and locations on the internet (I'll be referring to these as Uniform Resource Identifiers, or URIs).

When I say that HTTP <i>regulates</i> those interactions, I mean that it specifies <i>HOW</i> clients and servers <i>ARE ABLE TO</i> talk to each other. TCP/IP helps that talk actually happen (by regulating and directing packets of data)—not just on the Web but through email/p2p/FTP/etc.

<img src="http://croud.com/wp-content/uploads/2015/03/Centresource.jpg">

We can think of TCP/IP as a very organized truck convoy that's excellent at driving but doesn't really know what to do when it gets to its destination. HTTP is the dispatcher at every truck stop telling the truckers how to park and where to put the stuff on the back. If something's broken or not there, HTTP will shut the whole thing down.

<img src=
"http://inhabitat.com/wp-content/blogs.dir/2/files/2013/07/transformers-truck-lead.jpg">

<i>this metaphor kind of falls apart when we get to HTTP/1.1 and HTTP 2, which keeps connections to ports open, so the truck is now sort of vibrating on the dock and sending off paper airplanes and sometimes changing shape. Maybe those mean the truck is actually a Transformer</i><br>

In the most typical model of this truck/dispatcher interaction, the truck is carrying a message (which is typically 'hey, I'm here, give me some stuff') while the dispatcher is sitting and waiting for the request. When the request comes through, the dispatcher will then send back the requested stuff.<br>

This whole thing is called a GET method. Everything we send via a URL bar is a get method. When I go to www.example.com/index.html, that 'index.html' is a request for something called index.html.<br>

Sometimes you want to put stuff on a server, which means that the truck load is significantly heavier, and HTTP has certain ways of dealing with this data and making a it a subordinate of the receiving URI.<br>

This is called a POST method.<br>

(There are a handful of other methods, but let's stick to the basics.)<br>

So where do Ruby interfaces, gems, and objects fall into all of this?<br>

Let's start with the basic URI class. This comes in the Ruby library and deals with various URIs (not just HTTP but FTP etc.) The URI::HTTP module has a grand total of three methods. Two of them are dedicated to building a URI::HTTP object out of components (userinfo, host, port, path, query, fragment). That's all it does. It builds an object that gives me info about a location.<br>

Needless to say, that's a little primitive. It's certainly useful -- locations tell you a lot about what's happening. URI is also vital as part of HTTP -- it's one of two required parts, the HEAD.<br>

```
2.2.3 :004 >   uri = URI("http://www.ebay.com/sch/i.html?_from=R40&_trksid=p2060353.m570.l1313.TR0.TRC0.H0.Xmy+search.TRS0&_nkw=my+search&_sacat=0")
 => #<URI::HTTP http://www.ebay.com/sch/i.html?_from=R40&_trksid=p2060353.m570.l1313.TR0.TRC0.H0.Xmy+search.TRS0&_nkw=my+search&_sacat=0>
2.2.3 :005 > uri.scheme
 => "http"
2.2.3 :006 > uri.host
 => "www.ebay.com"
2.2.3 :007 > uri.path
 => "/sch/i.html"
2.2.3 :008 > uri.query
 => "_from=R40&_trksid=p2060353.m570.l1313.TR0.TRC0.H0.Xmy+search.TRS0&_nkw=my+search&_sacat=0"
2.2.3 :009 > uri.fragment
 => nil

```
URI is required to build a Ruby NET::HTTP object, which gets a little more interesting. HTTP objects can easily become a client that surfs the web just like we do.<br>

{% highlight ruby %}
 uri = URI('http://example.com/index.html')

Net::HTTP.start(uri.host, uri.port) do |http|
  my_get_request = Net::HTTP::Get.new uri

  server_response = http.request request
end
{% endhighlight %}

To break it down a bit further:<br>

{% highlight ruby %}

Net::HTTP.start #the HTTP.start method opens up a TCP/IP connection, just like a client does.

(uri.host, uri.port) #to do so, it calls on that host and port information

 do |http| #the block format is to keep using that same connection session for this bit of code

  my_get_request = Net::HTTP::Get.new uri # we're defining a Get request from that location

  server_response = http.request request # We're now making that specific request, and storing it in an HTTP response object
end
{% endhighlight %}

You can read this just like a html file if you use HTML's body method (e.g., "response.body").<br>

The big string that response.body returns should look familiar to you, especially if you've done any scraping. A tool like Nokogiri just breaks up that string into hash-like chunks via a parsing algorithm.<br>

An environmental tool like Rack (and Sinatra, which inherits from a number of Rack classes, and Rails which ultimately inherits from THAT) is designed to act like the opposite side of this transaction. So it will first RECEIVE the request and parse the data it gets from it, and then it will RETURN some data. As such, methods using these environments don't necessarily look a lot like HTTP methods, even though it's the same protocol!<br>

{% highlight ruby %}
class Request #the code behind a Rack request

    def initialize(env) #the environment here is the env of the REQUEST (typically just a head)

      @params = nil

      super(env) #this is inheriting from the main Rack module (which specifies and freezes a bunch of Net::HTTP verbs)

    end
{% endhighlight %}

The good news is that Rack is, among other things, designed to streamlined that HTTP request/response process we've just gone over. It takes all that stuff we associate with URI and the TCP/IP handling of the HTTP object by creating an environment and creating objects based on that environment.<br>

We can think of that environment as a server. There's a bunch of stuff on that server that we would need to deal with if it wasn't for Rack. A few of them are:<br>

<ul>
REQUEST_METHOD: The HTTP verb of the request. This is required.<br>
PATH_INFO: The request URL path, relative to the root of the application.<br>
QUERY_STRING: Anything that followed ? in the request URL string.<br>
SERVER_NAME and SERVER_PORT: The server's address and port.<br>
rack.version: The rack version in use.<br>
rack.url_scheme: is it http or https?<br>
rack.input: an IO-like object that contains the raw HTTP POST data.<br>
rack.errors: an object that response to puts, write, and flush.<br>
rack.session: A key value store for storing request session data.<br>
rack.logger: An object that can log interfaces. It should implement info, debug, warn, error, and fatal methods.
</ul>

 Rack and its babies and grandbabies lets you pass all that stuff to an initializing object in Hash form, turning it into an Object with variables that you can manipulate. You can send back another object, which Rack will turn back into HTTP-compliant data.<br>

Sinatra is fairly similar in this sense.

{% highlight ruby %}

def get(path, opts = {}, &block)
      conditions = @conditions.dup
      route('GET', path, opts, &block)

      @conditions = conditions
      route('HEAD', path, opts, &block)
    end
{% endhighlight %}

In short, then, HTTP gives us a sense of structure. Ruby has a bunch of useful stuff that interprets and rearranges that structure into something that's easy and pleasing to deal with, before sending it back as big ungainly (but STRUCTURED) chunks of data!
