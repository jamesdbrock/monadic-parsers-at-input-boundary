© James Brock 2022

# Monadic Parsing at the Input Boundary

This is a presentation for
[PureConf 2022 18 February](https://hasgeek.com/FP-Juspay/pureconf/)
about monadic parsers in general, and the
[__purescript-parsing__](https://github.com/purescript-contrib/purescript-parsing)
package in particular.

It’s intended for an audience who has a little familiarity with monads and
regular expressions, and who knows what an operating system “process” is.

## The Input Boundary

A process running on a computer is isolated from other processes on that
computer, and from the rest of the world. On that process boundary,
the process has input and output.
The process views its inputs and outputs as either discrete events like
signals and mouse clicks, or as byte streams. It can send byte streams to
files or sockets, and it can receive byte streams from files or sockets.

A “byte stream” also includes filenames, web brower form field values, GIFs,
or anything else represented in process memory as an array of bytes.

Sending a byte stream is easy. We write a byte stream and we send it,
there are no surprises.

When a process reads a byte stream, it must somehow turn the information
in the byte stream into a data structure in the process’s native language.
Reading a byte stream is difficult, because there may be surprises. We
expect the byte stream to have a certain structure, but it may not have that
structure. A large portion of process bugs, crashes, and security vulnerabilities
can be described as “misbehaving on suprises in an input byte stream.”
It is the act of interpreting input byte streams that we want to focus on
in this talk.

In the year 2022, here are some common methods of interpreting an input byte
stream.

1. Write an ad-hoc parser based on string splitting and regular expressions.
   This is how we end up writing a process which misbehaves on suprises.
2. Use a parser generator or parsing library like Google Protocol Buffers
   or JSON.
   This works okay as long as we control the format of the byte stream,
   which is often not true.
   The reason why such a huge amount of network traffic these days is JSON
   is exactly because reading a byte stream is difficult, and good JSON
   parsers exists for every language. People would rather mangle their
   data into JSON than read a byte stream.
3. Monadic parsers.

I will try to convince you that method number 3 is always the first method you
should reach for when reading a byte stream from over the process input
boundary.






---

<p align="center">
  <a href="https://revealjs.com">
  <img src="https://hakim-static.s3.amazonaws.com/reveal-js/logo/v1/reveal-black-text-sticker.png" alt="reveal.js" width="500">
  </a>
  <br><br>
  <a href="https://github.com/hakimel/reveal.js/actions"><img src="https://github.com/hakimel/reveal.js/workflows/tests/badge.svg"></a>
  <a href="https://slides.com/"><img src="https://s3.amazonaws.com/static.slid.es/images/slides-github-banner-320x40.png?1" alt="Slides" width="160" height="20"></a>
</p>

reveal.js is an open source HTML presentation framework. It enables anyone with a web browser to create beautiful presentations for free. Check out the live demo at [revealjs.com](https://revealjs.com/).

The framework comes with a powerful feature set including [nested slides](https://revealjs.com/vertical-slides/), [Markdown support](https://revealjs.com/markdown/), [Auto-Animate](https://revealjs.com/auto-animate/), [PDF export](https://revealjs.com/pdf-export/), [speaker notes](https://revealjs.com/speaker-view/), [LaTeX typesetting](https://revealjs.com/math/), [syntax highlighted code](https://revealjs.com/code/) and an [extensive API](https://revealjs.com/api/).

---

### Sponsors
Hakim's open source work is supported by <a href="https://github.com/sponsors/hakimel">GitHub sponsors</a>. Special thanks to:
<div align="center">
  <table>
    <td align="center">
      <a href="https://workos.com/?utm_campaign=github_repo&utm_medium=referral&utm_content=revealjs&utm_source=github">
        <div>
          <img src="https://user-images.githubusercontent.com/629429/151508669-efb4c3b3-8fe3-45eb-8e47-e9510b5f0af1.svg" width="290" alt="WorkOS">
        </div>
        <b>Your app, enterprise-ready.</b>
        <div>
          <sub>Start selling to enterprise customers with just a few lines of code. Add Single Sign-On (and more) in minutes instead of months.</sup>
        </div>
      </a>
    </td>
    <td align="center">
      <a href="https://www.doppler.com/?utm_cam![Uploading workos-logo-white-bg.svg…]()
      paign=github_repo&utm_medium=referral&utm_content=revealjs&utm_source=github">
        <div>
          <img src="https://user-images.githubusercontent.com/629429/151510865-9fd454f1-fd8c-4df4-b227-a54b87313db4.png" width="290" alt="Doppler">
        </div>
        <b>All your environment variables, in one place</b>
        <div>
          <sub>Stop struggling with scattered API keys, hacking together home-brewed tools, and avoiding access controls. Keep your team and servers in sync with Doppler.</sup>
        </div>
      </a>
    </td>
  </table>
</div>

---

### Getting started
- 🚀 [Install reveal.js](https://revealjs.com/installation)
- 👀 [View the demo presentation](https://revealjs.com/demo)
- 📖 [Read the documentation](https://revealjs.com/markup/)
- 🖌 [Try the visual editor for reveal.js at Slides.com](https://slides.com/)
- 🎬 [Watch the reveal.js video course (paid)](https://revealjs.com/course)

---

### Online Editor
Want to create your presentation using a visual editor? Try the official reveal.js presentation platform for free at [Slides.com](https://slides.com). It's made by the same people behind reveal.js.

<br>
<br>

--- 
<div align="center">
  MIT licensed | Copyright © 2011-2022 Hakim El Hattab, https://hakim.se
</div>
