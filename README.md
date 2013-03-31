Algorithmic Software Verification
=================================

Course Materials for Graduate Class on Algorithmic Software Verification

Requirements
------------

1. Scribe **one** lecture

2. Do **three** assignments
    - implement some of the above algorithms
    - use verification tools

3. Present one 40 minute talk
    - read 1-3 papers from the list below
    - prepare slides and get vetted by me
    - synthesize and present

Plan
----

Deductive Verification

1. Decision Procedures/SMT  [2]
    - EUIF
    - DIFF
    - DPLL
    - SMT
    - Proofs?

2. Contd.

3. Floyd-Hoare Logic        [2]
    - SP/WP
    - VCGen
    - SSA (Flanagan-Saxe)

4. Contd.

HW 1

5. Type Systems             [2]
    - Hindley Milner (?)
    - Local Type Inference/Bidirectional Checking
    - Subtyping

6. Contd.

7. Refinement Types         [2]
    - Refinement Type Checking
    - Subtyping + Implication + VCGEN

8. Abstract Refinement Types

HW 2

Algorithmic Verification

9. Horn Clauses (HMC) & Abstract Interpretation
    
10. AI: Theory 
    - Intervals/Octagons/Polyhedra

11. Predicate Abstraction (Liquid Types)
    - Interpolation ?

HW 3

Reasoning About the Heap

12. Separation Logic

13. Heap + Higher Order [HTT/Triple]

Reasoning About Untyped Languages

14. Nested Refinement Types

15. Heap + ... DJS

Project Lectures



List of Topics
--------------

- SAT/SMT
- Hoare Logic
- Types, Polymorphism, Subtyping
- Refinement Types
- Abstract Interpretation

- Horn Clauses/Fixpoint
- Liquid Types
- Heap & State
- Separation Logic
- Imperative Refinement Types
- Symbolic Model Checking, BDDs, Craig Interpolants
- *ADD MORE HERE*

List of Papers
--------------

- Termination (papers from Cook, et al) [here](http://research.microsoft.com/en-us/people/bycook/)

- Fancy First-Order Logics [HAVOC](google:qadeer-lahiri) [STRAND](google:partharasarathy)

- [JS*](http://research.microsoft.com/~nswamy/papers/dijkstra-submitted-pldi13.pdf)
  (Swamy et al, PLDI 2013)[here](http://research.microsoft.com/en-us/um/people/nswamy/papers/index.html)

- [Separation Logic and Abstraction](http://www.cl.cam.ac.uk/~mjp41/p205-parkinson.pdf)
  (Parkinson and Bierman, POPL 2005)

- [Abduction](http://www.cs.wm.edu/~idillig/pldi022-dillig.pdf)
  (Dilligs and Aiken, PLDI 2012)

- [Containers](http://www.cs.wm.edu/~idillig/popl2011.pdf)
  (Dilligs and Aiken, POPL 2011)

- HTT + [BedRock](http://adam.chlipala.net/papers/BedrockPLDI11/BedrockPLDI11.pdf)
  (Chlipala, PLDI 2011)

- Concurrency via Separation Logic (papers from Parkinson, Birkedal, et al)
  [here](http://research.microsoft.com/en-us/people/mattpark/)


- Dependently Typed Languages: 
    - [ATS](todo) 
    - [Agda](todo)
    - [Idris](https://edwinb.wordpress.com/2013/03/28/programming-and-reasoning-with-algebraic-effects-and-dependent-types/)


- Concurrency           [e.g. Mike Emmi's papers]
    via Sep Logic       [e.g. Jagannathan, Parkinson]
- Security              [papers of Gordon, Fournet, Bhargavan]

- [RockSalt](http://john-tristan.appspot.com/pubs/rocksalt.pdf)(Morrisett et al, PLDI 2012)

- [Dependent Types for ML](http://www.cs.purdue.edu/homes/suresh/papers/vmcai13.pdf)
  (Zhu and Jagannathan, VMCAI 2013)

- [Dafny](http://research.microsoft.com/en-us/um/people/leino/papers/krml203.pdf)
  (Leino) ([more benchmarks](http://research.microsoft.com/en-us/um/people/leino/papers/krml205.pdf))

- Security (papers of Gordon, Fournet, Bhargavan, et al) 
  [here](http://research.microsoft.com/en-us/um/people/adg/Publications/)

- IC3                   [Bradley]


- *ADD MORE HERE*


Homeworks
---------

HW 1: 

- EUIF + DIFF
- VCG for TJS
- Use VeriFAST

HW 2:

- BiDir Type Checking  for TJS
- Refinement Type VCGen for TJS 
- Use LiquidHaskell

HW 3:

- ConsGen for TJS
- PA for Horn Clauses
= Liquid Types for TJS


 
 
