## Outline

- intro to talk
- Forth intro
- new definitions
- what is a computer
- brief 64-bit Intel overview
- a threaded interpreter
- abstract model, W, I
- concrete model
- implementation in assembler
- operating system image loading
- forth in forth

## 000 I, David Jones


Thank you for this opportunity to speak to you.
It is an honour and a privilege to be here.

My name is David Jones and I'm here to tell you a little bit
about a Forth implementation.

Before that I'd like to give thanks to
and remember John Pinner.
My first public talk was 10 years ago,
and it was at the first PyConUK back in 2007.
And I have the bag to prove it!
John Pinner had organised it,
and I met him at the Birmingham Conservatoire
about 10 minutes before the talk I gave there.
John passed away in 2015, and
I am very pleased that we carry on his legacy by meeting in
conference.

## 010 In the beginning

I've probably had this urge for a long time,
but it was August 2016 when I tweeted it.
I was first exposed to Forth in the 1980s on an 8-bit micro.
I can't remember if it was the ZX81 or the ZX Spectrum,
but they both had typical Forth implementations of the era.

A friend suggested I buy this classic text on the right,
which is secretly a book about implementing Forth.
If you were here last year, you may have spotted me carrying the book.
It's great for starting conversations.

Loeliger's book is about implementing a Forth-like language
on the Z80 CPU, an 8-bit CPU that was very popular in the 1980s.


## 015 The URLs

My implementation, called SixtyForth,
follows the same pattern as Loeliger's but I'm
implementing it on a 64-bit Intel CPU architecture.

If you do an internet search for `sixtyforth`, then,
depending which search engine you use,
it either
suggests you have mispelt an extremely short musical note,
or ranks someone else's fork higher.
So add my github id for now, which is drj11


## A brief introduction to Forth

Let's look at Forth.

First, let's build it.

    make
    ./64th

It's interactive, and in a similar fashion to Python, has
a read evaluate loop.

Forth prints "ok" when it has successfully executed
all of the input.
Note that the "ok" typically appears on the same line
as the input, and is followed by a newline
(the reverse of the Python prompt convention).
A lot of what seems weird to us now in 2017
was already a Forth tradition with a 10 year legacy in 1980.

If we want to add two numbers, we use PLUS.
But in Forth, the numbers we want to add have to have already
been computed, so they come first:

    5 20 +

If you try this, you don't see any answer.
To see the answer, we can print a number using DOT.

    5 20 + .

In Forth PLUS and DOT are called WORDs.
WORDs are the things that actually do something.
Syntactically a WORD has a name,
and its name is any sequence of non-space characters.
Spaces (generally, any white space) are required to separate the
WORDs of a Forth program.

What's happening here is that Forth uses a stack,
called the Data Stack.
Most WORDs do something with the Data Stack.
PLUS takes two items off the top of the stack,
and replaces them with their sum.
So overall the stack shrinks by one item.

As a debugging aid, we can use the word `.s`
to print a sort of picture of the stack.

When .s shows the stack,
it prints the stack with the top of stack to the right,
which is the order that would have typed the values in
if they had been typed in,
and it's a convention used in most Forth documentation.

There are various words that manipulate the stack,
DUP, DROP, SWAP.
We're going to be using DUP, which duplicates items.

    5
    dup
    .s
    *
    .s

The numbers that we used above are different from WORDs,
when the interpreter sees a number,
it pushes the value of the number onto the stack.

## Definitions and Threaded Interpreters

To define new words in Forth,
which correspond to subroutines or functions in other languages,
we used a word called COLON, and spelt using the colon
punctuation character.

So let's say we want to square a number.
We can do that by duplicating it, then call STAR.

    : square  dup *  ;

This is an example of how we define a new word called SQUARE.
When we execute SQUARE it has the same effect as if its body
had been executed.
The word SEMICOLON ends the definition.

So the sequence

    5 square .

(which will print 25)

has the same effect as the sequence

    5 dup * .

Note how the definition of square doesn't include any parameter
definitions, and there are no return statements.
SQUARE, like every other word in Forth, by convention takes its
parameters on the data stack, and returns its result on the data
stack.
There are no declarations that make this explicit,
it's a byproduct of executing the body of the definition.

In this case, we can see that SQUARE takes the top-of-stack,
duplicates it, and then multiplies that number with its
duplicate, and so leaves the square on the top-of-stack.

Words defined like this appear just like any other words in Forth.
There is no difference between built-in and user defined words
or syntax.

At the keyboard, we can immediately use this new definition.

    5 square .

Note that `square` leaves its result on the stack,
like all Forth WORDs really.

If we want to square something twice, we can just call it twice:

    5 square square
    .

Can we see what's going on halfway through?
You have to be careful if you debug using `.`.
. consumes a stack item, so you often need to prefix it with
DUP:

    5 square  dup .  square

And of course we can use this newly defined word in a further
new definition:

    : cube  dup square *  ;

    5 cube

Computes the cube of 5, of course we've forgotten to print the
result. Which is still on the stack.

    .


## Let's look at the definition of CUBE again

A word is split into a Code Field and a Data Field
(traditionally called Parameter Field,
but the ANSI standard uses Data Field).

The Code Field is a single cell that holds the address of a
piece of machine code.
Words like CUBE and SQUARE, defined in Forth,
all share the same Code Field value,
the address of a piece of machine code that when executed
invokes the sequence of execution tokens found in the Data
Field.
As implied, the Data Field is the sequence of execution tokens
corresponding to the body of the definition.

For a primitive word, like DUP,
the Code Field value is the address of machine code that
performs the equivalent of DUP.
As is traditional, this implementation puts that machine code in
the Data Field of the word.
Otherwise the Data Field of primitives is unused.

## Execute CUBE

Let's more closely consider what happens when we call CUBE.

    5 cube

CUBE proceeds to call DUP, which duplicates the top of stack,
then it calls SQUARE, which itself calls DUP.

Let's pause for a moment.
When CUBE called SQUARE,
there has to be a piece of state, a marker,
that tells CUBE where to resume when SQUARE has finished.
Similarly, when SQUARE calls DUP, there has to be a marker that
tells SQUARE to resume when DUP has finished.

The definition of CUBE is a model for the process that occurs
when CUBE is called.
This process is fairly simple, the process is to call DUP, them
call SQUARE, then call STAR.

When SQUARE is called from CUBE,
the process of executing CUBE is temporarily suspended,
and a process to execute SQUARE starts.
When that process completes, we say SQUARE returns,
and the execution of CUBE resumes.

Suspending the execution of CUBE corresponds to remembering,
somewhere, where in the process we are,
so we know what to do when we resume.

This piece of information, where to resume when you are done,
is called Subroutine Linkage.

Another way of thinking about this is to consider the word DUP.
In this example, DUP is called from both SQUARE and CUBE.
When DUP is called and is finished, there has to be something
that tells us where to resume execution.
And, because DUP can be called from either SQUARE or CUBE,
or indeed, any new definition, that piece of information,
where to resume, has to be some sort of variable.

In this implementation of Forth,
I put this information on a Return Stack.
This is a very common choice, and encouraged by the language.

We can use a stack,
because subroutines have a stack-like behaviour.
After CUBE calls SQUARE, everything about that process is no
longer required, the answers are already on the Data Stack,
everything else we can throw away.

So, when CUBE calls SQUARE it pushes onto the Return Stack
a token that represents where in the CUBE definition to resume.
Similarly when SQUARE calls DUP it pushes onto the Return Stack
a token that represents where in the SQUARE definition to
resume.
When a word finishes, when it reaches the SEMICOLON,
it pops the token off the Return Stack and resume execution at
that point.

Those tokens i've represented here as CUBE+2 and SQUARE+1

This is quite an abstract model.

## Let's have a look at execution tokens

In Forth, the word TICK converts from name to execution token.

    ' dup
    .
    ' square
    .
    ' cube
    .

These numbers might seem mysterious, but they are not really.
They are just addresses, the address of the combiled form of the
word.

Notice that the execution token for cube is only a little bit
larger than the execution token for square.
The difference, 56 bytes, is the amount of memory used by the
definition of square.

Notice that the execution token for DUP is radically smaller.
The words that are builtin to the implementation are allocated,
by the operating system, into a different part of the address
space.

## A forth VM

The model for a threaded interpreter,
which is what I use looks like this

S and R manage the two stacks.

I is a pointer,
typically it points to somewhere in the middle
of the word we are executing.

W is the execution token for the word we are executing.
It's initially used to setup I at the beginning of executing a
word, but often isn't used after that.

Because i started the implemention of SixtyForth
before reading Conklin and Rather,
i have implemented a isomorphic VM, but with different names.
i apologise.

## A generic computer

To implement this Forth VM,
we need to translate it to an actual computer.
Here's a sort of generic computer.

Central Process Unit has a bunch of things inside it.
There are registers,
which are really the only thing the CPU knows how to "do
computation" on.
The Arithmetic Logic Unit is the thing that actually does
computation, like additions, multiplies.

Around the edge are units that talk to devices outside the CPU,
most siginificantly, a Memory Management Unit, that talks to an
array of memory, and some sort of Input Output unit which talks
to the slow slow slow mass storage, and network devices.

## Intel-64

This implementation runs on 64-bit Intel CPUs.
Such as the one in my laptop.
64-bits which is 8 bytes.

In terms of registers, we have a PC and 16 so-called General
Purpose registers.
which are named rAx rBx rCx rDx,
followed by RSP RSI RBP RDI
and then of course R8 through to R15

# Modelling the Forth VM

we have enough registers in Intel-64 that we can just assign
Intel-64 registers to equivalents in the Forth VM.
These choices represent a combination of what I thought might be
sensible given my very limited research,
and registers whose
name I could remember.

The Linux SYSCALL also uses some General Purpose registers,
and whilst I could use these, it's simpler not to.


## 110 layers

The current implementation consists of
an assembly file, and a Forth file.
These are combined into
a single Linux binary by NASM and the linker tools.

Some of the code is in assembly language.

Some of the code is in a compiled threaded form.

Some of the code is in Forth.

Let's have a look now at 64th.asm

PLUS: there is some noise at the top,
which is part of the Forth dictionary that
enables Forth to translate names into execution tokens.
In assembly the execution tokens are these labels on the left.
PLUS in this case.
This is pretty typical for a Forth word implemented in assembly.
It begins by copying data from the stack,
to the the CPU registers,
performs the add,
then adjusts the stack,
which is now smaller because we removed two items and pushed one,
then writes the result back to the stack.
Almost all of these Forth primitives end with a jump to next.

Threaded Code is the compiled form of Forth code.
Ideally in would be written in Forth,
but until we implement the Forth interpreter,
we can't write them in Forth.
There is nothing to interpret them.
So any words used in the implementation of the interpreter
have to be either in Assembly or already compiled into threaded
code.

greaterthan is a good example.
A is greater than B is equivalent to saying
B is less then A.
lessthan is already defined, in Assembler as it happens,
so we can define greaterthan in terms of lessthan.
This has a really simple definition in Forth,
but because the implementation of the interpreter needs it,
we have to write it in Threaded Code.

How do threaded words get executed?
Let's look at next, stdexe, and EXIT

If this seems like magic, it is

Forth in Forth

open rc.4
The definition of `2drop` is fairly typical.
`2drop` drops the top two items on the stack,
so we can have a simple implementation that calls DROP twice.
This definition is completely portable and will work on any
compliant Forth system.

The next word to be defined, is bit of strange one.
It is backslash, and it is a word that implements comments.
This scans the input until it finds a linefeed character,
then throws away, using 2DROP, that part of the input.
That what comments in source code are:
the bits that the computer throws away.
The 10 here, is the numeric code for a linefeed character.
This is the ASCII code for linefeed,
which is the line ending character on Unix.
So this definition in Forth is only useful on Unix systems.
A different definition would be required for Windows.

