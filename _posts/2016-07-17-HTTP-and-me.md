---
layout: post
title: HTTP and me
---

I've found myself wondering about how we talk to the internet, and how I do it through intermediaries like Sinatra —— because, right now, it really looks like magic. Magic is cool, but it's hard to talk about, so hopefully breaking it down helps!

<img src="https://www.cloudyn.com/wp-content/uploads/2014/07/18ky360ks3eccjpg.jpg">


As a refresher, Hyper Text Transfer Protocol regulates how we access stuff on the internet -- specifically interactions between clients and locations on the internet (I'll be referring to these as Universal Resource Identifiers, or URIs).

When I say that HTTP <i>regulates</i> those interactions, I mean that it specifies HOW clients and servers <i>ARE ABLE TO</i> talk to each other. TCP/IP helps that talk actually happen (by regulating and directing packets of data)—not just on the Web but through email/p2p/FTP/etc.

<img src="http://croud.com/wp-content/uploads/2015/03/Centresource.jpg">

We can think of TCP/IP as a very organized truck convoy that's excellent at driving but doesn't really know what to do when it gets to its destination. HTTP is the dispatcher at every truck stop telling the truckers how to park and where to put the stuff on the back. If something's broken or not there, HTTP will shut the whole thing down.

<figure>
<img src=
"http://inhabitat.com/wp-content/blogs.dir/2/files/2013/07/transformers-truck-lead.jpg">
<figcaption>(this metaphor kind of falls apart when we get to HTTP/1.1, which keeps connections to ports open, so the truck is now sort of vibrating on the dock and sending off paper airplanes and sometimes changing shape. Maybe HTTP1.1 means the truck is actually a Transformer)</figcaption>

In the most typical model of this truck/dispatcher interaction, the truck is carrying a message (which is typically 'hey, I'm here, give me some stuff') while the dispatcher is sitting and waiting for the request. When the request comes through, the dispatcher will then send back the requested stuff.

This whole thing is called a GET method. Everything we send via a URL bar is a get method. When I go to www.example.com/index.html, that 'index.html' is a request for something called index.html.

Sometimes you want to put stuff on a server, which means that the truck load is significantly heavier, and HTTP has certain ways of dealing with this data and making a it a subordinate of the receiving URI.

This is called a POST method.

(There are a handful of other methods, but let's stick to the basics.)

So where do Ruby interfaces, gems, and objects fall into all of this?

Let's start with the basic URI module. This comes in the Ruby library and deals with various URIs (not just HTTP but FTP etc.) The URI::HTTP module has a grand total of three methods. Two of them are dedicated to building a URI::HTTP object out of components (userinfo, host, port, path, query, fragment). That's all it does. It builds an object that gives me info about a location.

Needless to say, that's a little primitive. It's certainly useful -- locations tell you a lot about what's happening. URI is also vital as part of HTTP -- it's one of two required parts, the HEADER.

<!-- terminal output here  -->

URI is required to build a Ruby NET::HTTP object, which gets a little more interesting. HTTP objects can easily become a client that surfs the web just like we do.
{% highlight ruby %}
 uri = URI('http://example.com/index.html')

Net::HTTP.start(uri.host, uri.port) do |http|
  request = Net::HTTP::Get.new uri

  response = http.request request
end
{% endhighlight %}



Let's break this down. We'll recall that the URI object stores information about locations, which is why we're


{% highlight ruby %}

Net::HTTP.start #the HTTP.start method opens up a TCP/IP connection, just like a client does.

(uri.host, uri.port) #to do so, it calls on that host and port information

 do |http| #the block format is to keep using that same connection session

request = Net::HTTP::Get.new uri # we're defining a Get request from that location

  response = http.request request # We're now making that specific request, and storing it in an HTTP response object
end
{% endhighlight %}

You can read this just like a html file if you use HTML's body method (e.g., "response.body").

The big string that response.body returns should look familiar to you, especially if you've done any scraping. A tool like Nokogiri just breaks up that string into hash-like chunks via a parsing algorithm.

An environmental tool like Rack (and Sinatra, which inherits from a number of Rack classes, and Rails which ultimately inherits from THAT) is designed to act like the opposite side of this transaction. So it will first RECEIVE the request and parse the data it gets from it, and then it will RETURN some data. As such, methods using these environments don't necessarily look a lot like HTTP methods, even though it's the same protocol!

The good news is that Rack is, among other things, designed to streamlined that HTTP request/response process we've just gone over. It takes all that stuff we associate with URI and the TCP/IP handling of the HTTP object by creating an environment and creating objects based on that environment.

We can think of that environment as a server. There's a bunch of stuff on that server that we would need to deal with if it wasn't for Rack. A few of them are:

REQUEST_METHOD: The HTTP verb of the request. This is required.
PATH_INFO: The request URL path, relative to the root of the application.
QUERY_STRING: Anything that followed ? in the request URL string.
SERVER_NAME and SERVER_PORT: The server's address and port.
rack.version: The rack version in use.
rack.url_scheme: is it http or https?
rack.input: an IO-like object that contains the raw HTTP POST data.
rack.errors: an object that response to puts, write, and flush.
rack.session: A key value store for storing request session data.
rack.logger: An object that can log interfaces. It should implement info, debug, warn, error, and fatal methods.

(psst... this has a lot to do with satisfying HTTP requirements!) Rack and its babies and grandbabies lets you pass all that stuff to an initializing object in Hash form, turning it into an Object with variables that you can manipulate. You can send back another object, which Rack will turn back into HTTP-compliant data.

In short, then, HTTP gives us a sense of structure. Ruby has a bunch of useful stuff that interprets and rearranges that structure into something that's easy and pleasing to deal with, before sending it back as big ungainly (but STRUCTURED) chunks of data!
