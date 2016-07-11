---
layout: post
title: Printf and Sprintf
---

Printf and sprintf

Before creating this gem, I had limited experience with Ruby’s <i>print</i> function. I didn’t see much use for it – I love the automatic single-space newline in <i>puts</i> (and I use it extensively in the CLI!)

But when I found myself negotiating with displaying very specifically formatted information, I had to change my tune. Nokogiri saves text fields as strings automatically, which I turned into floats easily enough. But when it came time to display those prices again, I ran into an issue – “$30.0” technically makes sense, but it’s incorrect and, worse, looks sloppy.

So how could I get the standard $xx.xx formatting without messy lines of code for a seemingly simple task (and standardizing cases so that I could have the correct amount of decimal points for 100, 1000, etc.)? Enter sprintf. 

Why the crazy (and not very colloquial) name? The S at the beginning tells me that its function is to return /s/trings. The F at the end tells me that it’s going to require a /f/ormat sequence (or “format string”, depending on who you ask).

Sprintf and regular old printf don’t have to sit in methods. They’re rather versatile, used for justifying text alignment, creating placeholders, and (as in my case) managing floating points of decimal numbers. Mine are in methods, because I was trying to keep certain types of code limited to a CLI and others to an object class, which is why I opted for sprintf to get that nice clean string return.

Ultimately, the solution to my problem looked like this: sprintf('%.2f', (price.to_f + shipping.to_f))

This can be broken down as:
1) % -placeholder, my number.
2) .2f – ‘f’ for floating point argument, limited to 2 places by the ‘2’ that precedes it.
3) And I got to execute a little bit of math in the same line, using variables without issue! The second argument is what’s being fed into the first.

It’s not pretty or readable, but it is relatively neat once you understand it. So I guess the lesson is, there’s a use case for everything, even if you discount it at first.
