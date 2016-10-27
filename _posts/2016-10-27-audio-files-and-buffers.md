---
layout: post
title: WebAudioAPI
---

Because of job search stuff and a terrible case of misguided ambition, my React assessment exists only in my head. It is made only of wishes and dreams. Archaeologists (or monks, maybe?) will search for it like they do for Aristotle's lost work on comedy.

//name of the rose image

However, I haven't *not* been working on it. And part of that work has been looking into how web browsers play audio, which I now render unto you (rendering, for those paying attention, is exactly what my React assessment *isn't* doing). Specifically, I'm most interested in how a JavaScript app might play audio.

But first, of course -- a little history. [Wikipedia](https://en.wikipedia.org/wiki/Streaming_media) does a much better job than me at explaining this, but we can trace the history of streaming media back about 30 years, although most computers didn't have the processing power and most internet services didn't have the bandwidth to really make use of the technology. In the early 2000s, Flash became a "unified streaming option" and changed the game. (Shockingly, Flash is still used, but it's more helpful to see it as an inspiration for things like HTML5 and WebAudio -- unless you feel like learning ActionScript). As far as I can tell, Flash's big advantage is that it *is* scripted (its language is a superset of ECMAScript, like JavaScript. But instead of using JavaScript's prototype-based model, it reverts to a more Java-y system based on classes. Ironically, JavaScript has ALSO become more class-based and looks more Java-y these days... client-side scripting is all coming together!)

//bear hello image

But Flash had its limitations. The major one is that it's so closely tied to its vendor, so: enter WebAudio (which also has some struggles with proprietary versus open-sourced formatting). WebAudio, being based on a Mozilla API, is pretty strongly tied to the open source side of things.

WebAudio's been available in browsers since about 2012. It's based on the concept of an "audio graph" -- dedicated input and output nodes for audio. This model makes it more powerful than a simple audio player, because you can insert as many nodes as you want between input and output. The API comes with options for oscillation, spatialization, or other ways of deforming audio that you might fancy.

So let's take a look at the workflow for using the WebAudio API (I'll be ignoring the audio manipulation part, because I have no skill with it). Mozilla recommends the following:

1. Create audio context
2. Inside the context, create sources — such as <audio>, oscillator, stream
3. ~~Create effects nodes, such as reverb, biquad filter, panner, compressor~~
4. Choose final destination of audio, for example your system speakers
5. ~~Connect the sources up to the effects, and the effects to the destination.~~
