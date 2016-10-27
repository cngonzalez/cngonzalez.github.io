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

First, to set up the web audio context.

```
window.AudioContext = window.AudioContext || window.webkitAudioContext;
var context = new window.AudioContext();
```
(What is a web audio context? It's like the audio graph I mentioned earlier. It's basically an object that holds all the nodes and is able to talk to each and connect them together. Think of it like a Ruby wrapper module)

Anyway, that was easy! What's next?

In my case, I wanted to upload a file. What's the point of an audio player if I can't decide what to play? And I don't want to go around pressing buttons or whatever, so I'm going to set up my upload function to autoplay when it gets a file.

```
<input id="files" type="file" id="files" name="files[]" onchange='handleFileSelect(event);'/>
```
*Don't be like me. Don't embed your event listener into your HTML element. Do the right thing.*

That handleFileSelect function is going to create a source -- step number two! The source, however, is a little tricky. I can't just jam an MP3 there, because it's encoded and compressed; the WebAudioAPI wants audio *data*, not a formatted file. So I need to transform my MP3 into an binary data object (a blob! yay blobs!). The JavaScript format I've chosen for my blob is the ArrayBuffer.

```
function handleFileSelect(evt) {
  var files = evt.target.files; // FileList object
  playFile(files[0]);
}

function playFile(file) {
    var freader = new FileReader();
  // FileReader's onload function is a listener for when the file is fully loaded and read
    freader.onload = function (e) {
  //Remember, I want to autoplay as soon as this guy goes up. But I also want to have access to the blob for later, which is why I'm setting it to a buffer variable I declared earlier.
  //e.target.result, in this case, is the blob I want
        playSound(e.target.result, 0);
        buffer = e.target.result;
    };
//then I have to tell my FileReader to actually read the file! I can also set this to a variable, but because file reading is asynchronous, this would actually return a promise. With ES6, I can actually use a .done here, but I've had sketchy results.
freader.readAsArrayBuffer(file);
}
```

So now I've transformed my MP3 into a hideous blob.

\\blob from Xmen picture

 but I haven't actually told my audio context about it yet. That's happening in that playSound function, which looks like this:

```
function playSound(arraybuffer, startPoint) {
  context.decodeAudioData(arraybuffer, function (buf) {
    // creates new audio source node, which is an object that has exactly one output and no inputs
    source = context.createBufferSource();

    // this connects the node to my window so that I can play it. If I were a better audio engineer, I'd manipulate my audio with oscillators et al. here, before connecting it to my window
    source.connect(context.destination);

    //the source is just a node -- it doesn't know what it's playing yet. That's why I'm giving the return value of the audio decoding function to it.
    source.buffer = buf;
    source.start()
    });
}
```

And now my song will play!

There's one thing to keep in mind. A source node can only play once. When you stop it, it dies. There's some logic behind this (and I think it has roots to old-school audio engineering) -- you might play a thing multiple times, get stuck in a loop, etc. So the source node wants to only live once. You can hack a pause-and-play solution, but mine needs some fiddling:

```
startedAt = Date.now();
source.start(0, startPoint);
paused = false;
```

First, I add a start point. The 0 argument for my source.start() means I want it to start immediately (if I wanted it to wait 5 seconds, I'd put '5000' in there). The start point is defaulting to 0, but it's actually an offset.

You can see that offset in action in the handlePlayClick function:

```
function handlePlayClick() {
  if (paused) {
    playSound(buffer, (pausedAt / 1000)) //add 1000 or so here to take care of delay? Or possibly at the startedAt var?
    paused = false;
  }
  else {
    source.stop();
    pausedAt = Date.now() - startedAt;
    paused = true;
  }
}
```

And that's it! It's kind of broken! But happy musicking!
