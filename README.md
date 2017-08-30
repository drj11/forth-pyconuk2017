# A talk about Forth at PyConUK 2017

The goal is to leave the attendee with a taste of
what it is like to implement a language.
Hopefully some idea of how achievable it is,
and the idea that implementing a language
is something reasonably ordinary.


## REFERENCES

My original proposal is here:
https://github.com/drj11/pycon-2017-proposal

Loeliger: https://www.abebooks.com/book-search/isbn/007038360x/


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
