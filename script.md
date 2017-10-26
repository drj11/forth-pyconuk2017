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
suggests you have mispelt an extremely short musical note
or ranks someone else's fork higher.
So add my github id for now, which is drj11


## A brief introduction to Forth

Let's look at Forth.

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
Spaces (generally, any white space) is required to separate the
WORDs of a Forth program.

What's happening here is that Forth uses a stack,
called the Data Stack.
Most WORDs do something with the Data Stack.
PLUS takes two items off the top of the stack,
and replaces them with their sum.
So overall the stack shrinks by one item.

The numbers that we used above are different from WORDs,
when the interpreter sees a number,
it pushes the value of the number onto the stack.

## Definitions and Threaded Interpreters

To define new words in Forth,
which correspond to subroutines or functions in other languages,
we used a word called COLON, and spelt using the colon
punctuation character.

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

##

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
somewhere, where in the process we are, so we know what to do
when we resume.

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

We can use a stack, because subroutines have a stack-like
behaviour.
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

## This is quite an abstract model.

It is an effective model.
We can use it to describe behaviour and to reason about behaviour,
but if we want to implement the language, we'll need to get a
bit more concrete.

There are many ways to realise this model, but one of the
simplest is to use a threaded interpreter.
Again, this is a very common way to implement Forth,
and the language encourages it, but it is far from the only way.

To make our threaded interpreter,
we need a way to reduce each word in Forth to an Execution Token.
Each definition then becomes a sequence of Execution Tokens.
A return token, on the return stack, is the position of the next
item in the sequence of Execution Tokens.

They're all addresses.
An Execution Token for a word defined in Forth,
like SQUARE or CUBE, is an address in memory where the sequence
of Execution Tokens that correspond to its definition is found.

Some words actually have to do something! Like DUP, and TIMES.
Those words have Execution Tokens that are not the address of a
sequence of tokens but the address of a piece of machine code
that when executed has a suitable effect.

So we need a way of deciding if an execution token is a
primitive, or corresponds to a word defined in Forth.

A very traditional and very elegant way to model this is as
follows:

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
