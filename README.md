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


## Talk
### (slide) 0:30

My name is James Brock and I work at the AI consultancy
company Cross Compass in Tokyo.

This is my talk Monadic Parsers at the Input Boundary for PureConf 2022.

I am a maintainer for the PureScript `parsing` library, and the examples
in this talk will use syntax and type names from that library.

This talk is for an audience who has some familiarity with regular expressions and monads.

### (slide) 0:30

A process running on a computer is isolated from other processes on that
computer, and from the rest of the world. On that isolation boundary,
the process has input and output.
The process views its inputs and outputs as either discrete events like
signals and mouse clicks, or as byte streams.

The term “byte stream” includes any string-like thing, like filenames,
web browser form field values, entire files,
or anything else represented in process memory as an array of bytes.

We want to talk about byte streams.

### (slide) 1:00

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
all essentially similar. We will say that all of this means “parsing.”

It is the act of reading and parsing input byte streams that we will focus on
in this talk. We will be talking mostly about Unicode strings, but
everything in this talk will generalize to any kind of byte stream.

### (slide) 1:00

In the year 2022, here are some common methods of parsing an input byte
stream.

1. Write an ad-hoc parser based on string splitting and regular expressions.
   This is how we end up writing a process which misbehaves on surprises.
   It’s easy to make mistakes here and forget to handle certain cases.
2. Use a parser generator like Google Protocol Buffers.
   This works great as long as the input is in this format, but that
   is often not true.
3. Use JSON.
   Again, this obviously only works if the input is JSON.
   The reason why such a huge amount of network traffic these days is JSON
   is exactly because reading a byte stream is difficult, and good JSON
   parsers already exist for every language. People would rather mangle their
   data into JSON than write a custom byte stream parser.
4. __Monadic parser combinators__.

I will try to convince you that monadic parsing is the best method
for parsing any arbitrary input byte stream,
and this is always the first method you
should try when you are reading a byte stream from over the process input
boundary.

### (slide) 1:15

I'll read to you from the essay
[Parse, don't validate](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/)
by Alexis King.

> Consider: what is a parser? Really, a parser is just a function that consumes less-structured input and produces more-structured output. By its very nature, a parser is a partial function—some values in the (input) do not correspond to any value in the (output)—so all parsers must have some notion of failure.
>
> Under this flexible definition, parsers are an incredibly powerful tool: they allow discharging checks on input up-front, right on the boundary between a program and the outside world, and once those checks have been performed, they never need to be checked again! Haskellers are well-aware of this power.
>
> (A parser sits) on the boundary between your application and the external world. That world doesn’t speak in product and sum types, but in streams of bytes, so there’s no getting around a need to do some parsing. Doing that parsing up front, before acting on the data, can go a long way toward avoiding many classes of bugs, some of which might even be security vulnerabilities.

So, Alexis King is discussing the abstract idea of what it means to “parse” something.
She does not talk about monadic parsers or any kind of monads at all.
Her emphasis is on taking an unstructured input, like a byte stream, and turning
it into a data structure.

### (slide) 0:30

The data structure should ideally *make illegal states unrepresentable*.
This is a common proverb in the functional programming world.

It’s only possible to do this in programming languages which have a strong enough
type system that the compiler can check your code for you and prove that
certain things will always be true, and that certain invariants will hold.

If we parse our input byte stream into a data structure which makes illegal
states unrepresentable, then by producing an instance of the data structure
we have provided a proof that our input byte stream in in some sense ”legal.”

The easiest way to do this is with monadic parsers.

### (slide) 0:30

A parsing monad is a monad with three features: It knows its position in the
input string. It can choose alternate parsing branches based on the contents
of the input string. And it can fail in the case that the input string
is illegal and cannot be parsed.

There are many implementations of monadic parser combinators in many languages,
and all of them have these three features. These three features are necessary
for a parsing monad, and they are also sufficient. Any monad which has these
three features is a parsing monad.

### (slide) 2:00

Let's look at an example of matching a pattern with a monadic parser.

Here is the same pattern expressed with a regular expression and with a monadic
parser.

The pattern which we want to match is a string that starts with a lowercase ‘a’
character and then has either a lowercase ‘b’ character or an uppercase ‘B’
character.

Then we also want to capture the ‘b’ character, whether it was lowercase
or uppercase.

In the regular expression, we capture the ‘b’ by surrounding it with
parentheses.

In the monadic parser, we capture the ‘b’ character by returning it from
the monadic computation.

Let’s look at the monadic parser computation. It’s in the form of a `do`
block. On the first line of the `do` block we match a literal ‘a’ character and then
throw it away by binding it to the underscore variable. We don’t need to bind it to
a named variable because after we’ve matched
it then we don’t need it anymore.

Now remember that the parser monad has state inside of it which tracks the
current position in the input string. The act of successfully matching
the ‘a’ character will step the current input string position forward by one character.

On the next line of the `do` block we match a lowercase or uppercase ‘b’ character and bind it
to a variable named `x`.

The way that we say that `x` can be either lowercase ‘b’ or uppercase ‘B’ is
by using the alternative operator.

The alternative operator is kind of like the `or` operator,
which is why we write it as a bracketed vertical pipe character.

The alternative operator is a binary operator which takes two parsers as
arguments.
It first tries the left parser, and if that succeeds, then it returns
the result.
If the left parser fails then it tries the right parser and returns the result
of that.

So then after this alternative parser succeeds, the `x` variable will
contain either lowercase ‘b’ or uppercase ‘B’.

And then we return the variable `x` from the monadic computation.

Now let’s modify this parser slightly so that instead of returning the
captured ‘b’ character, it returns a data structure. Let’s return a very
simple data structure. What is the simplest data structure? It’s a single
bit. And a single bit contains all of the information we need about whether
the ‘b’ character was uppercase or lowercase.

### (slide) (slide back) (slide) 0:30

So now we’ve changed the type of the parser to return a `Boolean` instead
of a `Char`. The parser returns `true` if the parse succeeded and the
‘b’ character was uppercase.

This is an example of what we mean when we say that we want to return typed data structures
which make illegal states unrepresentable. There are only two possible
ways to successfully parse this string, and the data structure which we’re
returning has exactly two possible values, and no more.

### (slide) (slide back) (slide) 0:30

So recall that I said that a monadic parser needs three features:
* the state of the current position in the input string
* alternative
* and failure

Let’s see what happens when this `ayebee` parser fails. We gave it an
illegal string `"aXXX"` and instead of returning `Right` and a
`Boolean` data structure, it returned `Left` with a description and a position
for the error. The error says that it failed to parse because it was
expecting a ‘B’ character at position 2.


### (slide) 1:30

When we’re parsing patterns out of a string, a common thing to want to do
is pattern repetition.

Let’s try repeating the a-b pattern.

We added the asterisk quantifier to the regular expression to repeat the pattern
many times.

We also defined a new parser named `ayebeeMany`.
The `ayebeeMany` parser uses the `many` parser combinator to match the `ayebee`
pattern many times.

Let’s talk about what we mean by a parser combinator.

A parser combinator is a normal PureScript function. It is a function which
takes a `Parser` as an argument and then returns a new `Parser`.
The type of the data structure produced by the new parser may be different.

In this example you can see that the `ayebee` parser has
type `Parser String Boolean` because it is a parser from a string to a boolean.

We passed the `ayebee` parser as an argument
to the `many` parser combinator, and the `many` parser combinator returned
a new parser with type `Parser String (Array Boolean)`.

The data structure produced by the new parser will be an array of booleans.

So we run this new `ayebeeMany` parser and it matches the ayebee pattern
as many times at it can on the input string, and then returns an
array which is true for each of the matched ayebee patterns which had an uppercase
‘B’ character.

Parser combinators may take more than one parser argument.
For example, the alternative operator which we are using in the ayebee parser to match
either a lowercase ‘b’ character or an uppercase ‘B’ character is also, in fact,
a parser combinator. That alternative binary operator is a function
which takes two arguments, a left parser and a right parser. It returns a new
parser which tries first the left parser and then tries the right parser.

So parsers call parser combinators and pass parsers as arguments to the
parser combinators which return new parsers. This is how we build up
parsers for complicated pattern matching.

Let’s try writing our own parser combinator.

### (slide) 2:00

Here is a parser combinator which we have named `twice`. It is a lot like
the `many` combinator and in fact it has the same type signature.

The difference between the `many` combinator and the `twice` combinator
is that the `many` combinator will try to match its argument parser as many
times as possible, but the `twice` combinator will match its argument parser
exactly two times, no more, no less.

The `twice` combinator takes one parser as an argument, which we have named
`p`. The `p` parser can be any type of parser, which is what we mean by
`forall a.` The type parameter for the `p` parser is named `a`.

The `twice` combinator will first try to match the `p` parser, and bind
the result to the name `p1`. Then it will try to match the `p` parser
again, and bind the result to the name `p2`. If both of those succeed,
then it will return an array with `p1` and `p2`.

Down below we define and run a parser named `ayebeeTwice` with the same
input as before. You can see that the `ayebeeTwice` parser matches the
`ayebee` pattern two times, and returns true when the matched pattern has
an uppercase ‘B’ character.


So we can see that regular expressions and monadic parsers
both solve essentially the same pattern matching problem.

But the monadic parser is much longer than the regular expression and has
a lot more code. Is that bad?

The thing about regular expressions is that they seem like a reasonable
and efficient solution for small toy examples like these. But when
we take on larger and more complex problems, the advantage of monadic
parsers becomes apparent.

That’s analogous to the situation with pure functional programming.
It’s difficult to convey the advantage of pure functional programming
with small toy examples, because small toy programs are simple in any
language.

The advantages of pure functional programming become truly apparent
when we are maintaining and refactoring and improving large complicated
computer programs.

In the same way, the advantage of monadic parsing over regular expressions
becomes apparent when we are parsing more complicated patterns.


### (slide) 1:00


Let’s parse something a little bit harder. How about an email address?
We all have a pretty good idea what the format for an email address is.
Here is the complete Internet
Engineering Task Force specification for the format of an email address.
Okay, that’s a little bit hard. It’s not quite as simple as we might have
expected, but it’s not too bad.

Let’t think about what it says. The forward slashes in the syntax
mean “alternative” which means either the one on the left, or the one on
the right.

The square bracket syntax means that something is optional, so it's okay if that
thing is missing.

First the specification says that an address is either a mailbox or a group.

Then it says that a mailbox is either a name-addr or an addr-spec.

Then it says that a name-addr is an optional display-name followed by
an angle-addr.

Then it says that an angle-addr is an optional Comment Folding White Space
followed by a left-angle-bracket character followed by an addr-spec followed by a
right-angle-bracket character followed by an optional Comment Folding White
Space. Or, alternately, it can be an obs-angle-addr.

And it goes on like this.

Can we write a monadic parser to parse an email address?

### (slide) 0:30

Here is a monadic parser for parsing IETF email addresses, written by
Fraser Tweedale and published in the Haskell library __purebred-email__.

This is in the Haskell language and uses the Attoparsec parsing library.
The syntax for PureScript using the purescript-parsing library would be
almost exactly the same.

This monadic parser looks a lot like the Internet Engineering Task Force
specification.
Let's compare the specification and the monadic parser line by line.

### (slide) 1:30

First the spec says that an address is either a mailbox or a group.

The monadic parser says that an address is either a group or a single mailbox.

So the order of the alternative was flipped, but that’s fine. I’m sure
Fraser Tweedale had good reasons for doing that.

Next, the spec says that a mailbox is either a name-addr or an addr-spec.

In the monadic parser I see addressSpec on the right side of the
alternative, and that expression on the left side must be equivalent to a
name-addr, I guess. There is an `optional displayName`.
The `optional` function is a parser combinator
which does exactly what you’d expect: it will try to match the `displayName`
pattern one time but if the `displayName` pattern is not there then it
skips it.

Next, the spec says that an angleAddr is this addr-spec expression,
surrounded by angle bracket characters and optional Comment Folding
White Space expressions. Or, alternately an obs-angle-addr.

The monadic parser says basically the same thing.
I don’t see the obs-angle-addr alternative in the monadic parser for
angleAddr. Maybe we should open an issue with Fraser Tweedale and ask him about this.

Finally the spec says that a mailbox-list is either a comma-separated list
of mailboxes, or alternately an obs-mbox-list.

And the monadic parser also says that a mailboxList is a comma-separated list of
mailboxes. Again the monadic parser omits the alternative, I don't know why.

The point is that the formal spec for RFC 5322 and the monadic parser
implemented in Haskell are very similar. We can see what the monadic parser
is doing, and we can ask ourselves reasonable questions about the
implementation.

Next let’s look at the same RFC 5322 spec implemented as a regular expression.


### (slide) 1:00

The author of this regular expression claims that it quote
 “99.99% works” for parsing RFC 5322 email addresses.

And he may be right about that, but how can we tell?

The regular expression for RFC 5322 is shorter than the monadic parser, but it’s very
difficult to read it or make improvements.

This is why Regular Expressions are included in the pejorative Wikipedia
article about
[Write-Only Programming Languages](https://en.wikipedia.org/wiki/Write-only_language).

Here is a quote from the article:

> write-only code is source code so arcane, complex, or ill-structured that it
> cannot be reliably modified or even comprehended by anyone with the possible
> exception of the author.

Now, email addresses didn't start out as an Internet Engineering Task Force
specification. They were intended to be simple, and they started out simple.
In the 1970s an email address was a username and then an “at” sign and then
the name of a computer. We could parse that with a regular expression.

But over time email addresses became more complicated, as everything does.

Monadic parsers will scale and grow in a much more maintainable
way than regular expressions. And even small patterns written as a monadic
parser will be easier for others to read.


### (slide) 2:00

We often use regular expressions to scan a string and capture all of the
patterns which we find.

Here we want to find all of the integers in the string "10 x 2 y -3" and
split them out.

We’ve done this with both a regular expression and a monadic parser.

There are a couple of things to notice here.

First, the monadic parser for an integer doesn’t just match a string
pattern and return a string, it actually converts the string to an
integer and returns the integer. We’re using the `intDecimal` parser which
is included in the purescript-parsing library. The `splitCap` function
runs the `intDecimal` parser on this string and produces for us a fully typed
data structure which tells us everything there is to know about the structure
of the input string with respect to the integer patterns in the string.

The second thing to notice is that we made a mistake when we were writing
the integer pattern for the regular expression. We forgot to think about
whether we wanted to allow negative integers. Now, it’s easy to change
our regular expression so that it will allow negative integers, and I'm
sure you all know how to do that.

What’s hard is to take that improved integer regular expression pattern
and publish it in a library so that other people can avoid making the same
mistake. Of course, regular expression libraries do exist, and they contain
useful patterns like the email regular expression which we saw before. But
they really don't compose very well. The only way to compose regular
expressions together is to concatenate the regular expression strings.
This is because, again, regular expressions are a whole
domain specific language which is embedded in some other host language.
Regular expressions don't have any of the composition features like
functions and modules that we expect from general-purpose programming
languages.

Monadic parsers, on the other hand, are just normal PureScript functions,
and they compose very well. We’ve seen how to compose monadic parsers
together by writing parser functions with parser combinators.
Remember that the term ”parser combinator” just means a function
which takes some parsers as arguments and then returns a new parser.


### (slide) 2:30

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

I want to repeat one of the key points about monadic parsers: They are written in
normal PureScript. Parsing input is such a hard problem that when people
want to do it they traditionally use a whole domain-specific language for parsing.
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
have to turn the captured string into a data structure.

Remember that we looked at the problem of extracting integers out of some input string.
We wrote a regular
expression which found integer-looking substrings and we ran it on the input
string. The regular expression found some matches and returned the captured substrings.
Suppose we then ran a string-to-integer conversion function on a captured substring,
and the string-to-integer conversion function failed. What then? Was the captured
substring a legal integer string, or wasn't it?

In monadic parsers, we turn the string into a data structure in our native
language during the parse, so there is no ambiguity about whether or not
the input string was legal. In this case the “data structure” is an integer.
That is a very simple data structure, but it is a data structure. If we have
a thing which is not an integer then we can’t represent it as an integer,
so producing an instance of the integer data structure provides a proof that the
input string was legal.

Monadic parsers allow us to match patterns in normal PureScript instead
of using a domain-specific parsing language like regular expressions.
And after we have matched a pattern we produce a data structure which
preserves the proof that the input string was legal.

### (slide) 0:45

Here is a type for a monadic parser.

This is an excerpt from the 1998 paper
[FUNCTIONAL PEARLS *Monadic Parsing in Haskell*](https://www.cs.nott.ac.uk/~pszgmh/pearl.pdf)
by Graham Hutton and Erik Meijer.

On the bottom line is says that
the type of a parser for a data type `a` is a function from a string to a list
of pairs of an `a` and a string.

This simple type definition tells us pretty much everything we need to know
about monadic parsers, after we spend some time thinking about it.
Like all good math it has a simple definition but complicated
and far-reaching implications. Modern monadic parser libraries usually
don't use this exact type definition for a parser, but they use definitions
which are equivalent.

The essay
[*Revisiting Monadic Parsing in Haskell*](https://vaibhavsagar.com/blog/2018/02/04/revisiting-monadic-parsing-haskell/)
by Vaibhav Sagar has some good discussion about that.

### (slide) 0:30

If that last definition was too prosaic for you then, here is the same
definition expressed as a poem, by Fritz Ruehr.

Dr. Seuss on Parser Monads:

> A Parser for Things
>
> is a function from Strings
>
> to Lists of Pairs
>
> of Things and Strings!

Ok that's enough theory. We’ll stop at the Doctor Seuss level of parsing
theory. We don’t actually need to know any theory
to use monadic parsers, but now you know that the theory exists and
that the theory and techniques have been pretty well-established since the 1990s.


### (slide)

In a JavaScript runtime environment, you can expect a PureScript monadic
parser to run at least 10 times slower
than a JavaScript regular expression.

That's just how it is, and that situation probably will not improve much
in the future.

If your input byte stream will be large and you need to process it quickly
then you might not be able to use PureScript monadic parsers.

### (slide)

All of the techniques we talked about here are also used in Haskell.
There are Haskell monadic parsing libraries such as Attoparsec which run
very fast, about as fast as regular expressions, sometimes faster.

So if you learn these monadic parsing techniques then you can apply them
in other execution environments very well.


### (slide)

Whenever your process receives a byte stream from the world
beyond the process input boundary, the first thing you
should do is to parse that byte stream into a data structure.

Monadic parsers are the easiest and most effective way to do that.

Unless you already have a parsing library for the specific format of the
byte stream or you are under severe performance constraints, the first
technique you should consider for parsing an input byte stream is
monadic parsers.

Thank you very much for listening to my talk.



# References

[__purescript-parsing__](https://pursuit.purescript.org/packages/purescript-parsing)

[__purescript-parsing-replace__](https://pursuit.purescript.org/packages/purescript-parsing-replace)

[*Parse, don't validate*](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/)

[*Monadic Parser Combinators*](https://www.cs.nott.ac.uk/~pszgmh/monparsing.pdf)

[FUNCTIONAL PEARLS *Monadic Parsing in Haskell*](https://www.cs.nott.ac.uk/~pszgmh/pearl.pdf)

[*Revisiting Monadic Parsing in Haskell*](https://vaibhavsagar.com/blog/2018/02/04/revisiting-monadic-parsing-haskell/)

[*Parsec: Direct Style Monadic Parser Combinators For The Real World*](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/parsec-paper-letter.pdf) by Daan Leijen and Erik Meijer.

[*Write-Only Language*](https://en.wikipedia.org/wiki/Write-only_language).




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
