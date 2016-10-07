---
layout: post
title: Bundlers and loaders
---

One of the things that bothers me the most about Javascript development is the amount of Stuff(tm) that goes on behind-the-scenes in a modern JS app. There's stuff to compile all your files together, stuff to translate your code for a modern browser, stuff that your frameworks need to run, stuff that glues all your plugins together, and so on and so on. People are having a lot of fun right now with [How it feels to learn Javascript in 2016](https://hackernoon.com/how-it-feels-to-learn-javascript-in-2016-d3a717dd577f#.xeg7joeyh). But hopefully a little education on the topics covered there will take away some of the stress!

The concept of bundling your modules together shouldn't feel new. In a Ruby/Rails app you type `bundle install` which basically does the same thing -- a wizard comes out of your computer and makes everything in your app needs play together nicely. But the Ruby community is so nice and the Rails framework is so... dictatorial... that everything is more or less standardized. Even if you include a bunch of crazy gems and custom CSS and Javascript, I know where to find all of it, and I know (more or less) how that app is handling it.

Javascript is the Wild West, comparatively. Frameworks are constantly changing. Libraries change the game. People keep adding onto the language and saying that their changes will become 'official' next year (editorial note: they are *lying*). Another reason that this is all so crazy? JS JUST added certain forms of module support natively in its language, even though module structure has existed since 2009. Another crazy thing? NO browsers natively support modules, although they're used on basically every modern web app (the reason for this is that browsers are really, really hard to make, and modules are incredibly dynamic and varied).

But what IS a module? Like a Ruby file, it's a miserable pile of secrets.

![https://s-media-cache-ak0.pinimg.com/originals/6b/1b/12/6b1b12642d86a8283a6adeb5c7ae705a.jpg]

Asking what a module is like asking how long a piece of string is. It's just some code, and the functionality and purpose of your module should be clear (like -- there's a clear reason why a Ruby class is self-contained, and why a Ruby helper has the things that it has). As web apps become larger, they need more stuff. Keeping all of that stuff and loading it via script tags on HTML pages, and finding it later and maintaining it, all becomes a nightmare.

There are other, more Javascript-y reasons for separating your concerns, too -- if you want to avoid conflicts between variable names, if you want faster load times, if you want to ensure some listener is NEVER triggered on a certain page, if you want some element to be loaded everywhere without constantly rewriting the element, and so on.

Generally, there are several ways of interpreting module structure, even within a single JS page. You could use:
* **Anonymous closures**, which hide variables from the global environment by creating and executing things within an anonymous function.
* **Global import**, popularized by libraries like JQuery, where there are tons of variables within the global namespace, but they're rarely altered on a global scale -- only within local functions. By the addition of the `import` and `export` functions in ES6, it's easy to see that this is a popular approach.
* **Pseudo-classes**, which borrow object orientation from other languages, in attempts to create objects that can't be altered except by certain methods. The `class` function was also added in ES6, because of how widely-spread the Object.prototype way of creating classes had been.
* **Nested functions**, so that you can make a hierarchy of functions, dictating which has what kind of access to namespaces.

(If I had to hazard a guess, I'd say that, architecture-wise, AngularJS falls somewhere between anonymous closure and global import, while React lives pretty firmly in OO/class territory.)

These are very general and abstract summaries of JavaScript design patterns, but they'll hopefully help provide some introduction to the principles that inform modern module management. All of these pertain to the old issue of having your JS compiled in one big file, which is rarely the case anymore. But the theory behind them is still in play.

##CommonJS##

Much of what I've encountered in the Learn track is based on CommonJS (because most of the labs use NPM as their bundler, which is a Node product, which is based on CommonJS). A CommonJS file will have `module.exports` on the bottom (or, now, `export default`), and possibly require other modules (which have also been exported to the module) via an `import` or `require` function.

It's very neat and easy-to-understand (we've required and exported things enough to know that code can read other code), but it does have some drawbacks. It takes a server-first approach, which means that most of the work is being done on the server and then being served to the client. It synchronously loads modules to accomplish this, which can be less-than-ideal; most browsers will block any activity from happening until the LAST module is loaded.

##AMD##

![http://i.imgur.com/YOfDH51.jpg]

If you've gotta go fast, then AMD might be the framework for you. It uses `define` as a keyword for naming its dependencies, and allows all kinds of things to be modules -- strings, numbers, JSON, etc. CommonJS only allows objects to be modules, as far as I know. Unfortunately, server-oriented features like io and filesystem don't like AMD very much, which means that you are somewhat limited in your options in you want to read and write files, upload things, etc.

##Others##

Some frameworks like UMD try to combine AMD and CommonJS. I haven't heard much about it, but good luck to them.

##Plain old vanilla JS##

Yay! It's 2016 and ECMA2015 is here??? I mentioned earlier that JavaScript just added native support for modules. It's true! And it looks a lot like CommonJS! The main difference is that ES6 imports live read-only versions of modules -- CommonJS makes a copy of the module and loads THAT.

Anyway, that's how modules are imported and exported. So why do we need to talk about anything else? Why do Webpack and Browserify exist?

#Bundling#

Like Ruby files, all of my modules are living in different files for my own sanity. Also for my own sanity, let's say I, like most devs, am now depending on some external library (in my real-life case, this is currently React, but even JQuery counts here). And if I want my page to work right, I want to load all my stuff. So I write `<script src="MyStuff.js"></script>` about a dozen times.

And the browser loads it one by one, and my visitor can't do anything until it's done.

And -- oh no, my visitor left my page!

Loading modules one by one is slow. So now common practice is to put it all together in one big file. Then it gets minified, which means that it becomes unreadable to humans -- all of the variables are renamed to short strings, there's no more whitespace, etc. -- but it becomes a bit faster to load. In addition to speed, I'm also ensuring that my visitor's browser is able to find everything properly, because it's all in one big file (no partially loaded/dead frames here) and that their browser is able to interpret it.

Even if they're using Internet Explorer.

![https://i.imgflip.com/ti60l.jpg]

Browserify and AMD bundlers pretty do what I said above -- you run a command and everything ends up for you in bundle.js or similar. Webpack is a little different.

##Webpack##

Webpack's big difference is 'code splitting' -- it can run code in chunks, as can be seen by its config file.

```
var HTMLWebpackPlugin = require('html-webpack-plugin');
var HTMLWebpackPluginConfig = new HTMLWebpackPlugin({
  template: __dirname + '/app/index.html',
  filename: 'index.html',
  inject: 'body'
});

module.exports = {
  entry: __dirname + '/app/index.js',
  module: {
    loaders: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        query: {
          presets: ['react', 'es2015']
        }
      }
    ]
  },
  output: {
    filename: 'transformed.js',
    path: __dirname + '/build'  
  },
  plugins: [HTMLWebpackPluginConfig]
};
```
Fun fact: Antoin and I struggled for an hour trying to get React working with a tiny app I was making. It was fixed by adding react to the Webpack loader query. Thanks, Webpack!

There's debate over whether Webpack or Browserify is better. I've had more experience with Webpack, but a lot of people have issues with Webpack's require overloading (that is, in JS files you want to include in Webpack, you have to explicitly state what you're requiring at the top of the file). I like how explicit it is, but what do I know!

Now that ES6 can *theoretically* handle modules natively, it'll be interesting to see how all this changes in the future, or if the need for all this complexity will be reduced. We'll see!
