##

To define new words in Forth,
which correspond to subroutines or functions in other languages,
we used a word called COLON, and spelt using the colon
punctuation character.

    : square  dup *  ;

This is an example of how we define a new word called SQUARE.
When we execute SQUARE it has the same effect as if its body
had been executed.
The word SEMICOLON ends the definition.

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

    7 square .

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

Another way of thinking about this is to consider the word DUP.
In this example, DUP is called from both SQUARE and CUBE.
When DUP is called and is finished, there has to be something
that tells us where to resume execution.

This piece of information, where to resume when you are done,
is called Subroutine Linkage.

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

This is quite an abstract model.

Let's make it more concrete.
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
