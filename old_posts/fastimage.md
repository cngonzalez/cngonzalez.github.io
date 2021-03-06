---
layout: post
title: File and FastImage
---

I figured I'd continue my series on native Ruby modules that gems will help you bypass (see the HTTP and Sprintf posts for more of this kind of thing). Today I'm thinking about File objects.

I used a gem myself in my Sinatra assessment to determine the dimensions of uploaded images -- the fast and elegant FastImage. I was able to accomplish most of the other tasks required by the assessment without help, but dimensions were beyond me.

But because I don't like leaving stones unturned, I had a look at the FastImage source code.

```
def self.size(uri, options={})
    new(uri, options).size
  end
```

^^ Well, that's unhelpful. All I can tell is that calling size on the FastImage class makes a new FastImage instance. So what's up with that instance?

```
def initialize(uri, options={})
   @uri = uri
   #I omitted options stuff here

   if uri.respond_to?(:read)
     fetch_using_read(uri)
   else
     begin
       @parsed_uri = Addressable::URI.parse(uri)
     rescue Addressable::URI::InvalidURIError
       fetch_using_file_open
     else
       if @parsed_uri.scheme == "http" || @parsed_uri.scheme == "https"
         fetch_using_http
       else
         fetch_using_file_open
       end
     end
   end
```

Okay. We're getting a little closer. FastImage seems to be trying different ways of getting at the file address I'm trying to feed it, and then using an appropriate fetch mechanism it's defined. Since I'm interested in files, let's look at that 'fetch_using_file_open' method.

```
def fetch_using_file_open
    File.open(@uri) do |s|
      fetch_using_read(s)
    end
  end
```

File.open! I know what that does. I don't know what it does with a picture, though...

<img src='../images/ohno.png'>
<br>

So what on earth is that fetch_using_read doing to make sense of this mess? From checking the other bits of the code, it looks like the program is checking a chunk of the file for a filetype (by looking at how the data is presented in a stream) and then using this info to determine a size. Phew.

Thankfully, this is a pretty specific use case. What's important to know is that Ruby is able to access many bytes of info without being distracted, like we are, by pretty pictures.
