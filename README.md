# A talk about Forth at PyConUK 2017

The goal is to leave the attendee with a taste of
what it is like to implement a language.
Hopefully some idea of how achievable it is,
and the idea that implementing a language
is something reasonably ordinary.


## REFERENCES

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

find the "discovered" quote.

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
