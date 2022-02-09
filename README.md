© James Brock 2022

# Monadic Parsers at the Input Boundary

This is a presentation for
[PureConf 2022 18 February](https://hasgeek.com/FP-Juspay/pureconf/)
about monadic parsers in general, and the
[__purescript-parsing__](https://github.com/purescript-contrib/purescript-parsing)
package in particular.

## Abstract

When reading a byte stream over the process I/O boundary,
the first thing which everyone should do is to parse the
byte stream with a monadic parser.

The talk will discuss

- Processes and input byte streams.
- Monadic parsers. What they are and why they matter.
- The design and use of the
  [__purescript-parsing__](https://pursuit.purescript.org/packages/purescript-parsing)
  library.
- How to use monadic parsers instead of regular expressions with the
  [__purescript-parsing-replace__](https://pursuit.purescript.org/packages/purescript-parsing-replace)
  library.
- When not to use monadic parsers.

This talk is intended for an audience who has some familiarity with monads and
regular expressions. This talk is inspired and informed by the essay
[Parse, don't validate](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/)
by Alexis King.


## The Input Boundary

My name is James Brock and I work as a programmer at the AI consultancy
company Cross Compass in Tokyo.
This is my talk Monadic Parsers at the Input Boundary for PureConf 2022.

(slide)

A process running on a computer is isolated from other processes on that
computer, and from the rest of the world. On that isolation boundary,
the process has input and output.
The process views its inputs and outputs as either discrete events like
signals and mouse clicks, or as byte streams.

The term “byte stream” includes any string-like thing, like filenames,
web browser form field values, GIFs,
or anything else represented in process memory as an array of bytes.

For output, a process serializes byte streams.
Serializing a byte stream is easy. We write a byte stream and we send it.
There are no surprises.

For input, a process deserializes a byte stream.
Deserializing a byte stream is hard. When a process reads a byte stream,
it must somehow turn the information
in the byte stream into a data structure in the process’s native language.
Reading a byte stream is difficult because there may be surprises. We
expect the byte stream to have a certain structure, but it may not have that
structure. A large portion of process bugs, crashes, and security vulnerabilities
can be characterized as a process misbehaving when it encounters surprises in
an input byte stream.

We have many different terms we use to talk about deserializing a byte stream,
including “decoding,“ “validating,” “lexing,” “tokenizing,” and
“pattern matching.” These different terms describe activities which are
all essentially similar. They are all “parsing.”

It is the act of reading and parsing input byte streams that we will focus on
in this talk. We will be talking mostly about Unicode strings, but
everything in this talk will generalize to any kind of byte stream.

(slide)

In the year 2022, here are some common methods of parsing an input byte
stream.

1. Write an ad-hoc parser based on string splitting and regular expressions.
   This is how we end up writing a process which misbehaves on surprises.
2. Use a parser generator or parsing library like YACC or
   Google Protocol Buffers or JSON.
   This works okay as long as we control the format of the byte stream,
   which is often not true.
   The reason why such a huge amount of network traffic these days is JSON
   is exactly because reading a byte stream is difficult, and good JSON
   parsers exists for every language. People would rather mangle their
   data into JSON than parse a byte stream.
3. __Monadic parser combinators__.

I will try to convince you that monadic parsers is always the first method you
should reach for when reading a byte stream from over the process input
boundary.

(slide)

## Parsing

I'll read to you from the essay
[Parse, don't validate](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/)
by Alexis King.

> Consider: what is a parser? Really, a parser is just a function that consumes less-structured input and produces more-structured output. By its very nature, a parser is a partial function—some values in the (input) do not correspond to any value in the (output)—so all parsers must have some notion of failure.
>
> Under this flexible definition, parsers are an incredibly powerful tool: they allow discharging checks on input up-front, right on the boundary between a program and the outside world, and once those checks have been performed, they never need to be checked again! Haskellers are well-aware of this power.
>
> (A parser sits) on the boundary between your application and the external world. That world doesn’t speak in product and sum types, but in streams of bytes, so there’s no getting around a need to do some parsing. Doing that parsing up front, before acting on the data, can go a long way toward avoiding many classes of bugs, some of which might even be security vulnerabilities.

Alexis King is discussing the abstract idea of what it means to “parse” something.
She does not talk about monadic parsers or any kind of monads at all.
Her emphasis is on taking an unstructured input, like a byte stream, and turning
it into a data structure.

(slide)

The data structure should ideally *make illegal states unrepresentable*.
This is actually a common proverb in the functional programming world.
It’s only possible to do this in programming languages which have a strong enough
type system that the compiler can check your code for you and prove that
certain things will always be true, and that certain invariants will hold.

If we parse our input byte stream into a data structure which makes illegal
states unrepresentable, then by producing an instance of the data structure
we have provided a proof that our input byte stream in in some sense ”legal.”

The easiest way to do this is with monadic parsers.

(slide)
## Monadic parsers

I’ll read to you from the introduction to the paper
[*Parsec: Direct Style Monadic Parser Combinators For The Real World*](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/parsec-paper-letter.pdf) by Daan Leijen and Erik Meijer.

> Parser combinators have always been a favorite topic amongst functional programmers.
> Burge already described a set of combinators in 1975 and they
> have been studied extensively over the years by many others.
>
> In contrast to parser generators that offer a fixed
> set of combinators to express grammars, these combinators are manipulated
> as first class values and can be combined to define new combinators that fit
> the application domain. Another advantage is that the programmer uses only
> one language, avoiding the integration of different tools and languages (Hughes,
> 1989).

This is one of key points about monadic parsers: They are written in
normal PureScript. Parsing input is such a hard problem that when people
want to do it they traditionally use a whole domain-specific language.
The most famous domain-specific language for parsing is regular expressions,
but there are many others.

There has long been a tradition of general-purpose languages which are so weak
that it's impossible to write anything in them which is slightly hard, like
parsing an input byte stream.

The whole point of the Perl programming language is that it’s a weak
imperative-style language with regular expressions built-in so that we
can use regular expressions for parsing input byte streams.
That’s the whole point of Perl.

But it doesn’t really solve the problem in a satisfactory way. When our
computer program consists of two different languages, then we have the usual
problem of language interoperation. And the usual solution to language
interoperation is to pass strings. A regular expression can “capture” a pattern
in a string, but then it returns the captured pattern back to the host
language as a string. And then what do we do with the string? We still
have to turn the captured string into a data structure which makes illegal states
unrepresentable.

Suppose I want to extract an integer out of some input string. I write a regular
expression which finds integer-looking substrings and run it on the input
string. The regular expression finds a match and returns the captured substring.
Then I run a string-to-integer conversion function on the captured substring,
and the string-to-integer conversion function fails. What then? Was the captured
substring an integer, or wasn't it?

In monadic parsers, we turn the string into a data structure in our native
language during the parse, so there is no ambiguity about whether or not
the input string was legal. In this case the “data structure” is an integer.
That is a simple data structure, but it is a data structure. If we have
a thing which is not an integer then we can’t represent as an integer,
so producing an instance of the data structure provides a proof that the
input string was legal.

Monadic parsers allow us to match patterns in normal PureScript instead
of using a domain-specific parsing language like regular expressions.




A parsing monad is a monad with three features: It knows its position in the
input string. It can choose alternate parsing branches based on the contents
of the input string. And it can fail.

Let's look at an example of matching a pattern with a monadic parser.

Here is the same pattern expressed with a




### Readability

Here is another example of a pattern expressed with a regular expression.
The author of this regular expression claims that it will be correct
for 99.99% of RFC 5322 email addresses.

He may be right about that, but how can we tell?

A monadic parser would be a much longer program, but it would be possible
to read that program to determine if it is correct.














The parser syntax looks worse, why is it better?

We can decide what to parse next depending on the value of what the B was.

Make illegal states unrepresentable. A quick review of Parse, don't validate.

Quick explanation of do-notation.

Mention monad transformers, tie it into Jordan's talk

type-safety means the compiler can verify that we have accounted for all possible
surprises in the input byte stream


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
