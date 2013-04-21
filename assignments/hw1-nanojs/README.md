**HW 1: Due May 5, 2013**

README
=======

Tiny subset of ECMAScript for experimenting with verification algorithms

nano-js is the basis for the programming assignments in 

    http://goto.ucsd.edu/~rjhala/classes/sp13/cse291

Requirements
------------

Due to dependency on the SMT solver Z3, liquid-fixpoint and hence,
nano-js can **only be compiled on Linux** at the moment.


In addition to the .cabal dependencies, to build you must have

- the GNU multiprecision library 
- a recent OCaml compiler
- the CamlIDL library

The above can be carried out in one shot on a recent Linux by

    sudo apt-get install haskell-platform ocaml camlidl g++ libgmp3c2

Install 
-------

Make sure your machine has the above **requirements**.

**Step 1** Execute the following commands

    git clone git@github.com:ucsd-progsys/liquid-fixpoint.git 
    cd liquid-fixpoint && cabal install && cd ../
    
    git clone git@github.com:UCSD-PL/language-ecmascript.git
    cd language-ecmascript && cabal install && cd ../ 
    
    git clone git@github.com:ucsd-pl/algorithmic-software-verification.git
    cd assignments/hw1-nanojs/ 
    cabal install 

From now on, **we assume you are inside the directory**

    algorithmic-software-verification/assignments/hw1-nanojs

**Step 2**. After subsequent modifications, rebuild (in `assignments/hw1-nanojs`) with 

    make

or if you prefer

    cabal install

**NOTE:** We strongly recommend the use of `hsenv` to address cabal 
dependency issues. It works like a charm.

Run
---

After building run the verifier with

    $ nanojs tests/pos/skip.js 

If all went well you should see something like


    (liquid)rjhala@goto:~/teaching/algorithmic-software-verification/assignments/hw1-nanojs
    (master)$ nanojs tests/pos/skip.js 
    nano-js © Copyright 2013 Regents of the University of California.
    All Rights Reserved.
    nano-jsConfig {files = ["tests/pos/skip.js"], incdirs = []}
    
    main defined at (file: tests/pos/skip.js, 1, 1)
    formals: 
    requires:  true
    ensures:  true
    nanojs: 
    ****************************** ERROR *****************************
    ****************************** ERROR *****************************
    ****************************** ERROR *****************************
    FILL THIS IN 4
    ****************************** ERROR *****************************
    ****************************** ERROR *****************************
    ****************************** ERROR *****************************

After filling in the right code for `generateAssumeVC` (and `make`) you
should see something like:

    nano-js © Copyright 2013 Regents of the University of California.
    All Rights Reserved.
    nano-jsConfig {files = ["skip.js"], incdirs = []}
    
    main defined at (file: skip.js, 1, 1)
    formals: 
    requires:  true
    ensures:  true
    
    ****************************** DONE:  Safe *****************************

Running All Tests
-----------------

To run all the tests you can do

    $ make test

There are two kinds of tests, 

- programs which verify `tests/pos` 
- programs which should not verify `tests/neg`

Writing Specifications
----------------------

NanoJS takes two kinds of specifications,

1. **Loop Invariants**, for example, see `tests/pos/while5.js`
2. **Function Contracts**, for example, see: `tests/pos/inc-fun.js`

Assignment
----------

You need to do two things to complete the assignment.

## Part A: Verification Condition Generation

Fill in the implementation of VC generation for NanoJS by
completing the relevant implementations in:

    hw1-nanojs/Language/Nano/ESC.hs

in particular, at each place it says,

    errorstar "FILL THIS IN"

To begin with, skip the implementations for 

- `generateFunAsgnVC` 
- `generateReturnVC` 

These functions respectively handle the case for **call**  

    x = f(e);

and **return** statements

    return e;
 
Thus, you can complete all the tests *without* real function calls
(i.e. ignoring spec calls to `invariant`, `assert` and `assume`) 
without implementing the above.

Once you have successfully completed all the non-function tests, 
proceed to complete the above two functions.

**NOTE:**  You can **only** modify/extend the code in 
`Language/Nano/ESC.hs` there is no need whatsoever to 
change any code elsewhere. Of course, if you have some
ways of **improving** the assigment: be it simply better
documentation, tests, restructuring of code, then 
**please send me a pull request**.

## Part B: Verifying A Small Suite of NanoJS Programs

Next, use your implementation to **verify** the suite of programs in

    tests/pos/*.js

To do this, you will have to understand the code in order to determine
suitable loop-invariants, and function contracts, that you will then put
into the .js file.

**NOTE:** You can can **only** write specification annotations of the form 
    
    requires(p)
    ensures(p)
    invariant(p)

when verifying the files in 
   
    tests/pos/*.js

That is, you **cannot** add, remove or modify **any** other lines. 
(Of course, when **debugging** your specifications, you can make 
whatever modifications you like; we just require that the **final** 
versions adhere to the above requirement.)


HINTS:
------

0. There is a [hoogle server](http://goto.ucsd.edu:8082) that can help
   navigate the various libraries being used here, e.g.

    language-ecmascript
    liquid-fixpoint
    nano-js

   Use it to search for functions, and navigate the code base.

1. Understand the exported (public) API of 

    Language.Nano.Types, 
   
   especially some values, like: 

    returnSymbol, pAnd, pOr
   
   and the `Monoid` and `Functor` instances for `VCond`.

2. Similarly, understand the exported API of 

    Language.Nano.VCMonad

3. Instead of writing big invariants like:

    `invariant(p1 && p2 && p3);`

   You can split it into:

    `invariant(p1); invariant(p2); invariant(p3);`

   The same applies for `requires` and `ensures`.

4. Since the VCGen happens using a monad to log "side-conditions", 
   you may find the `<=<` operator quite handy. For example, to 
   generate the VC for a sequence of commands 

      `c1;c2;c3`

   that is to compute

      `generateVC (c1; c2; c3) vc` 

   you can do something like

      `(generateVC c1 <=< generateVC c2 <=< generateVC c3) vc`

   See the given implementation of `generateFunVC` for a complete example.


5. Make sure you understand:

        `Language.Fixpoint.Types.Subable`

   [see this](http://goto.ucsd.edu/~rjhala/llvm-haskell/doc/html/liquidtypes/Language-Haskell-Liquid-Fixpoint.html#t:Subable)
   
   You will need to implement substitutions, as needed for x := e, etc.

        `Language.Fixpoint.Types.Symbolic`

   [see this](http://goto.ucsd.edu/~rjhala/llvm-haskell/doc/html/liquidtypes/Language-Haskell-Liquid-Fixpoint.html#t:Symbolic)

   You may need this to convert program variables `Id a` to logical symbols `F.Symbol`

        `Language.Fixpoint.Types.Expression`
   
   [see this](http://goto.ucsd.edu/~rjhala/llvm-haskell/doc/html/liquidtypes/Language-Haskell-Liquid-Fixpoint.html#t:Expression)

   You may need this to convert program expressions `Expression a` to logical expressions `F.Expr`

        `Language.Fixpoint.Types.Predicate`

   [see this](http://goto.ucsd.edu/~rjhala/llvm-haskell/doc/html/liquidtypes/Language-Haskell-Liquid-Fixpoint.html#t:Predicate)
    
   You may need this to convert program expressions `Expression a` to logical predicates `F.Pred`

    (For the last three, the relevant class instances are in `Language.Nano.Types`)


