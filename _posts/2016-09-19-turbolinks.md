---
layout: post
title: Turbolinks and you
---

Turbolinks, as far as I can tell, was born in 2012, like so many other things: Hurricane Sandy, a failed Mayan apocalypse, and having to actually take Tea Partiers seriously.

Turbolinks is arguably not as bad as any of the above, but, like the above, it is something to be endured. Necessity is the mother of invention, and Turbolinks' necessity came about from the emergence of single-page apps. SPAs are still something many design philosophies aspire to, and the desire to create or emulate them came about for a number of reasons:

<ul>
* **Mobile-first development.** A page refresh takes forever on a phone. Better to have the user wait and sit for an initial load and never again.
* **Applications requiring persistent states.** As people began to work almost exclusively online, few had patience for not being able to navigate away from an email, for example, or return to a dedicated shopping cart page when comparing products.
* **Simple impatience.** Those tiny spaces of white page loads add up, especially when you're consuming a great deal of content online - reading pages of someone's blog or trying to find a recipe becomes a chore, even if the initial millisecond load time seems insignificant at first.
</ul>

A number of solutions to the SPA aspiration came about around this time -- hacks to HTML4 that would eventually become HTML5, frameworks like Ember and Angular (React is a special case, since it decided to drop even pretending to be a model or controller framework), and Bootstrap 2. It seems like Rails developers were unwilling to be late to this particular party, so: enter Turbolinks.

Turbolinks attempts to mock SPA behavior by minimizing elements of a page that are being refreshed. All of your assets are compiled right at the top, so when a view calls them, there's less wait time. But the fastest thing of all is that your page is not rendering each time you change URLs.

How does this work, exactly?

<img src="http://blog.honeybadger.io/images/2015/09/pjax-requests.jpg">
*I've linked an image of PJAX here, which is closely related to Turbolinks but not quite Turbolinks. PJAX replaces part of the document body. Turbolinks replaces the whole body, every time.*

It may be easier to think about Turbolinks if we look at the step-by-step process a user using a Turbolinks-enabled site goes through. It's something like this:

1. I click a link.

2. Turbolinks fetches that clicked link asynchronously (meaning that it happens out of step with my DOM load, and that the DOM will continue to exist in its current state and I can still manipulate it while Turbolinks is busy grabbing my data for me)

3. Now my page is loaded, as if I'd just typed a new address in the bar and navigated there organically. My browser addressed even changed! What a great time!

So if my browser address changed, I must have loaded up a brand new page, right?

Yes and no. In 2014, HTML5 introduced a method with the very Javascript-y name of pushState. PushState MIMICS the changing of a DOM without actually doing it -- it gives apps the ability to rewrite the address bar even within the same DOM load.

(Why would anyone want to do this? Well, because in a perfect world, URLs should designate unique resources. While it's technically possible to navigate a big CRUDy website with just the URL "www.mywebsite.com" persisting through every page, it's a bit jarring. It also stops me from sending URLs of my hilarious cat gifs to my friends, and will make me extremely confused and scared to use my back button.

In short, it seems like a psychological measure for internet users, who are historically easily upsettable.)

So the relevant content is loaded and all seems well. Except now none of my Javascript event listeners are firing, my main page background color is the same color as my landing page, and I have to refresh to see certain pieces of content load.

What happened?!

Turbolinks. Turbolinks happened. If you, like me, vaguely remember Javascript and CSS out of books and in an environment that happened before the craze for native-seeming web applications, you set up events to happen on the successful load of a page, and assumed that your CSS wouldn't stick around for two more "page loads" (and remember, they're not page loads - pushState is LYING to you).

So I could use all kinds of convoluted workarounds, or, more commonly, just delete that pesky little "require turbolinks" line in my manifest (I have done this multiple times now). But there are some defenses for Turbolinks. Sometimes, <a href="http://blog.steveklabnik.com/posts/2012-09-27-seriously--numbers--use-them-">it IS faster. </a> in the interest of optimism, here's some solutions I found to help you live in peace with Turbolinks:

* Use its native methods instead of JQuery's $(document).ready(). You can find a list of these here: https://github.com/turbolinks/turbolinks-classic#events. They include such useful methods as page:change and page:update.

* Ditch RESTful redirects. One of the issues I've come across is trying to patch JQuery methods into an app that was already fully RESTful in a Rails way. JQuery would demand you just use Javascript to update your view. If you go in with that expectation -- rather than trying to get a perfect page upon redirect -- you'll run into fewer errors.
