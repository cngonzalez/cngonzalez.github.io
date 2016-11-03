---
layout: post
title: Rails 5 and Active Record
---

Building a new project in Rails 5 after having learned Rails mostly through Rails 4 didn't present many issues, but there were a few hiccups that are worth enumerating here -- for future generations who may also get stuck for a few hours with a simple method that they could have sworn worked a few days ago (like I did).

The one most pertinent to me was .build. My assessment has an "element" object that is dependent on parent "page" object. Users never see or interact with this element object -- it's just a way to logically divide the moving pieces that go into making a page. As child objects, they're created via a nested form, and should, in theory, be instantly instantiated upon creation with their parent page objects, via a handy method provided in Rails to a parent object called "accepts_nested_attributes_for".

But wait! When I tried to create these objects via their forms, everything was broken. The pages were saving, but all their most interesting parts -- the elements that belonged to them -- were all coming up nil. I eventually guessed that, because elements belonged to a page, they couldn't be saved because I was telling them to belong to a page that didn't technically exist in the database yet (since I'd set the elements to create at the same time as their parent object).

For the record, this worked in Rails 4.

It seems that one of the biggest changes in Rails 5 was, in fact, an update to the Active Record belongs_to association. In previous versions of Rails, you could create a belongs_to record independently. In some ways, this is illogical -- can a cart exist without a shopper? Is a student really a student without classes? -- and seems to be implemented to prevent data inconsistencies. The stringency here seems also to help with data persistence; no more old records that belong to things that no longer exist.

You can still have it the old way, by adding the "optional:true" argument to the :belongs_to line in your table.

Other cool things Rails 5 gives you is an update to some ARel arguments. In addition to where.not, you get where.or. Also, all rake tasks can now be run with the rails prefix (e.g., rails db:migrate). In general, this seems to be a move toward greater unity between the things Rails unites -- Rack stuff, ARel, ActiveRecord, and Ruby 2.2.
