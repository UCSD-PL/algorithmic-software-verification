**HW 2: Due Jun 14, 2013**

README
=======

Language for experimenting with verification algorithms

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

    cabal update
    cabal install language-ecmascript 
    git clone git@github.com:ucsd-progsys/liquid-fixpoint.git 
    git clone git@github.com:ucsd-pl/algorithmic-software-verification.git
    cd assignments/hw2-liquid/ 
    make


From now on, **we assume you are inside the directory**

    algorithmic-software-verification/assignments/hw2-liquid

**Step 2**. After subsequent modifications, rebuild (in `assignments/hw2-liquid`) with 

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


    make tests

To run individual test:

    nanojs liquid path/to/test

Running All Tests
-----------------

To run all the tests you can do

    $ make test

There are two kinds of tests, 

- programs which verify `tests/liquid/pos` 
- programs which should not verify `tests/liquid/neg`


Writing Specifications
----------------------

`nanojs liquid` takes two types of specifications or annotations:

1. *refinement types*  which generalize loop invariants and contracts.

2. *qualifiers* these are predicate fragments from which refinement types
   are inferred via predicate abstraction.

   There are many examples of both in `include/prelude.js`, also see:

            tests/liquid/pos/inc.js
            tests/liquid/pos/cousot.js
       
   for examples. And see:

            include/prelude.js

   for a list of "default library" qualifiers. You can DELETE
   all the qualifiers (or just remove the "@") to see the exact
   set needed for each program.

   Only edit `prelude.js` for debugging. 
   
   **rebuild** `make` before running or changes to `prelude.js` will not be reflected...

Assignment
----------

You must do only three things:

1. Fill in all the `error "TO BE DONE"` in Language/Nano/Liquid/Liquid.hs

2. Add type qualifiers and/or type specifications to the files in `liquid/tests/pos`

3. Add *3* new **interesting** test cases in `tests/liquid/pos/`

So that, when you are done, running

    make tests

yields the happy

    "All tests pass :D"

**NOTE:**  You can **only** modify/extend the code in 

    `Language/Nano/Liquid/Liquid.hs` 

there is no need whatsoever to change any code elsewhere. Of course, if you
have some ways of **improving** the assigment: be it simply better
documentation, tests, restructuring of code, then **please send me a pull
request**.


Hints
-----

1. There is a [hoogle server](http://goto.ucsd.edu:8082) that can help
navigate the various libraries being used here, e.g.

    language-ecmascript
    liquid-fixpoint
    nano-js

Use it to search for functions, and navigate the code base.

2. use `tracePP`

3. See lecture notes: https://github.com/UCSD-PL/algorithmic-software-verification/blob/master/web/slides/lec-refinement-types-3.markdown

You are essentially implementing the typing rules shown there.

step 1. fresh* return types with templates
step 2. "typechecking" as in Liquid/Liquid.hs will generate constraints over templates
step 3. these are solved by "fixpoint"

        verifyFile f   = reftypeCheck f . typeCheck . ssaTransform =<< parseNanoFromFile f
        reftypeCheck f = solveConstraints f . generateConstraints  

You only implement "step 2" 

    > Only need to fill in code in Language/Nano/Liquid/Liquid.hs

    > See "HINTS" to see how to get fresh templates for unknown types for 
        + phi-vars                  (`freshTyPhis`)
        + function signatures       (`freshTyFun`)
        + polymorphic instantiation (`freshTyInst`)

4. Debugging will be **HARD**: use `tracePP` and related functions aggressively.

    + modify envAdds    to log the types/template
    + modify subType/s  to see EXACTLY what constraints are being added at each site.
    + stare at .fq files to see what the generated constraints look like.
    + use the `ssaTransform'` (instead of `ssaTransform`) if you
      want to see the output SSA.
    + the recorded templates and constraints for each binder will be saved 
      in `foo.js.annot`. look at it to make sure the right templates/types 
      are being inferred.
    + for several benchmarks, you will need to write EXTRA
      QUALIFIERS (predicates) from which the right types can be
      inferred. 
    + Figuring out the extra qualifiers may be the hardest part of
      the assignment. Or not. When in doubt, put in EXPLICIT 
      refinement type signatures, corresponding to how you think
      each function should behave...


