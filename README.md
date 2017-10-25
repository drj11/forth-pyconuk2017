# A talk about Forth at PyConUK 2017

The goal is to leave the attendee with a taste of
what it is like to implement a language.
Hopefully some idea of how achievable it is,
and the idea that implementing a language
is something reasonably ordinary.


## REFERENCES

Anjana Vakil's talk on Python bytecodes
https://twitter.com/AnjanaVakil/status/756421996200751104

My original proposal is here:
https://github.com/drj11/pycon-2017-proposal

[LOELIGER] Loeliger,
https://www.abebooks.com/book-search/isbn/007038360x/

[DIMENSIONS5.2] FORTH Dimensions, Volume 5, Number 2.
http://forth.org/fd/FD-V05N2.pdf

[MOORE1999] Forth, the Early Years; a 1999 reprint.
http://worrydream.com/refs/Moore%20-%20Forth%20-%20The%20Early%20Years.pdf

[RATHER1993] The Evolution of Forth.
https://www.forth.com/resources/forth-programming-language/


## The spelling FORTH

Moore believed that he was creating a new language paradigm
beyond the existing 3rd generation languages
of Fortran, Algol, and Cobol,
and chose the name Fourth.
Moore was programming on an IBM 1130 at the time,
and the disk system restricted names to 5 upper-case characters.
Hence FORTH F-O-R-T-H was born. [RATHER1993]


## Forth Versions

Language versions, a favourite topic at PyConUK.

Who is using Modern ANSI Forth 2004?

Who is using the much-maligned Forth-83 standard?

And who is using the venerable Forth-79?


## The Key Implementation Ideas

Words are reduced to an execution token (which is a cell).

The execution token is the Code Field Address.

The Code Field contains the address of machine code.

Immediately following the Code Field is the body.

For ordinary words defined in Forth,
the body is a vector of execution tokens.

Scanning source input is as simple as possible.


## Loeliger

Last year, at PyConUK 2016
I was carrying around this book [LOELIGER] so that
if I found a private quiet spot,
I had something to read.
To my surprise it proved to be a great conversation starter.

The book is ancient history now, published in 1981,
it describes the implementation of a forgotten language
on an almost forgotten CPU architecture (the Zilog Z80).
There simply aren't very many descriptions of
programming language implementations,
and Loeliger's unusual account is clear
and gives insight into
the background and motivation behind some of the design decisions.

## Moore

find the "discovered" quote.  It's in the FAQ.

## Syntax

Moore uses the term "context free".
I think this is meant in the context-free grammar sense.


## Ethics

The ethics of Forth are actually pretty terrible.
Forth's compact and efficient aesthetic makes it
a good match for embedded systems.

In a 1983 interview [DIMENSIONS5.2] the founder of Forth, Moore,
discusses putting it inside infra-red-guided self-seeking bullet.
So Forth is already being discussed in the context of killing people.


## Assembly labels are Forth execution tokens

The Forth model is embedded in the Assembly model.
An example of this is the execution tokens for Forth definitions.
In the model I've chosen,
the execution token of a definition is its Code Field Address.
In the Assembly model,
I've labelled the Code Field Address for a definition
with its name.
That means that in both Assembly and Forth
a definition's name stands for its execution token.

## From ASM to Threaded

Things get simpler and clearer
when you move from ASM to Forth.
At least some of the time.

Consider change ecaba958de3c1fb93151d06a829ceb0988a44a3f
where I replace the ASM implementation of 2SWAP
with a Threaded implementation.
At this point in the implementation of SixtyForth
my own stack skills were getting better.
And I realised I could replace these 8 assembly language
statements:

    mov rax, [rbp-32]
    mov rcx, [rbp-24]
    mov rdx, [rbp-16]
    mov rsi, [rbp-8]
    mov [rbp-32], rdx
    mov [rbp-24], rsi
    mov [rbp-16], rax
    mov [rbp-8], rcx

with this one line of Forth:

    rot >r rot r>

This was an elegant moment.
However, I couldn't use the Forth implementation,
as `2SWAP` is used by builtins that are required by
the interpreter, and so are Threaded themselves.

## What's Core?

- data stack: DUP DROP SWAP
- return stack: >R R> R@ 2>R
- comparison: 0= 0 0< < U<
- flow: BRANCH, 0BRANCH, EXIT
- memory: @ ! CMOVE
- bitwise: INVERT XOR OR AND BIC
- arithmetic: + - 1+
- IO:
- dictionary:
- compiler:


## Coroutines

This is hilarious.
A non-recursive single coroutine can be implemented with:

    : co 2r> swap 2>r ;

Implementation:
https://github.com/jeelabs/embello/blob/master/explore/1608-forth/hmv/d#L104

As pointed out by Wippler https://jeelabs.org/article/1612b/

## Surprises

Surprised that the Linux `SYSCALL` ABI trashes the RCX register
on return.

Annoyingly difficult to work out what size the buffer for the
TCGETS IOCTL should be.

I had forgotten the terrible Direction Flag in Intel
architecture.

I was pleasantly surprised by the accuracy and comprehensiveness
of the Stack Overflow answer to my first (and so far only)
Stack Overflow question.

Following a tutorial really makes you implement things,
and not push them down the line.
If the tutorial calls for ?DO or +LOOP to work,
then they really have to work.
