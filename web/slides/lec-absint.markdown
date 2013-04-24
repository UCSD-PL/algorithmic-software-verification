% Abstract Interpretation
% Ranjit Jhala, UC San Diego
% April 22, 2013

## Fundamental Challenge of Program Analysis

**How to infer (loop) invariants** ?

## Fundamental Challenge of Program Analysis

- Key issue for any analysis or verification

- Many algorithms/heuristics

- See [Suzuki & Ishihata, POPL 1977](http://dl.acm.org/citation.cfm?id=512963)

- Most formalizable in framework of **Abstract Interpretation**

## Abstract Interpretation

``A systematic basis for *approximating* the semantics of programs"

- Deep and broad area

- Rich theory

- Profound practical impact

We look at a tiny slice

- In context of algorithmic verification of **IMP**


## IMP: A Small Imperative Language

Recall the syntax of IMP

~~~~~{.haskell}
data Com = Var `:=` Expr            -- assignment
         | Com `;`  Com             -- sequencing
         | Assume   Exp             -- assume 
         | Com `|`  com             -- branch
         | While Pred Exp Com       -- loop
~~~~~

### Note

We have thrown out `If` and `Skip` using the abbreviations:

~~~~~{.haskell}
Skip        == Assume True
If e c1 c2  == (Assume e; c1) | (Assume (!e); c2) 
~~~~~

## IMP: Operational Semantics

### States

A `State` is a map from `Var` to the set of `Values`

~~~~~{.haskell}
type State = Map Var Value
~~~~~

## IMP: Operational Semantics

### Transition Relation

A subset of `State` $\times$ `Com` $\times$ `State` formalized by

- `eval s c ==  [s' |` command `c` transitions state `s` to `s']`

~~~~~{.haskell}
eval                :: State -> Com -> [State]
eval s (Assume e)   = if eval s e then [s] else []
eval s (x  :=  e)   = [ add x (eval s e) s ]
eval s (c1 ; c2)    = [s2 | s1 <- eval s c1, s2 <- eval s' c2]
eval s (c1 | c2)    = eval s c1 ++ eval s c2
eval s w@(Whle e c) = eval s $ Assume !e | (Assume e; c; w)) 
~~~~~


## IMP: Axiomatic Semantics

### State Assertions 

- An assertion `P` is a `Predicate` over the set of program variables.

- An assertion corresponds to a **set of states**

~~~~~{.haskell}
states P = [s | eval s P == True]
~~~~~

## IMP: Axiomatic Semantics 

Describe execution via **Predicate Transformers** 

### Strongest Postcondition 

~~~~~{.haskell}
SP :: Pred -> Com -> Pred
~~~~~

`SP P c` : States **reachable from** `P` by executing `c`

~~~~~{.haskell}
states (SP P c) == [s' | s <- states P, s' <- eval s c]
~~~~~

## IMP: Axiomatic Semantics 

Describe execution via **Predicate Transformers** 

### Weakest Precondition 

~~~~~{.haskell}
WP :: Com -> Pred -> Pred
~~~~~

`WP c Q` : States that **can reach** `Q` by executing `c`

~~~~~{.haskell}
states (WP c Q)` = [s | s' <- eval s c, eval s' Q ]
~~~~~

## Strongest Postcondition 

`SP P c` : States **reachable from** `P` by executing `c`

~~~~~{.haskell}
SP              :: Pred -> Com -> Pred

SP P (Assume e) = P `&&` e

SP P (x := e)   = Exists x'. P[x'/x] `&&`  x `==` e[x'/x]

SP P (c1 ; c2)  = SP (SP P c1) c2 

SP P (c1 | c2)  = SP P c1 `||` SP p c2

SP P w@(W e c)  = SP s (Assume !e | (Assume e; c; w))  
~~~~~

- **Uh Oh!** last case is non-terminating ...

## Weakest Precondition 

`WP c Q` : States that **can reach** `Q` by executing `c`

~~~~~{.haskell}
WP              :: Com -> Pred -> Pred

WP (Assume e) Q = e `=>` Q

WP (x := e)   Q = Q[e/x] 

WP (c1 ; c2)  Q = WP c1 (WP c2 Q) 

WP (c1 | c2)  Q = WP c1 Q `&&` WP c2 Q

WP w@(W e c)  Q = WP (Assume !e | (Assume e; c; w)) Q
~~~~~

- **Uh Oh!** last case is non-terminating ...

## IMP: Verification (Suspend disbelief regarding loops)

### Goal: Verify Hoare-Triples

Given 

- `c` command
- `P` precondition 
- `Q` postcondition

Prove 

- **Hoare-Triple** `{P} c {Q}` which denotes 

~~~~~{.haskell}
forall s s'. if s  `in` (states P) && 
                s' `in` (eval s c)
             then
                s' `in` (states Q)
~~~~~

## Verification Strategy

(For a moment, suspend disbelief regarding loops)

1. Compute Verification Condition (VC)

    - `(SP P c) => Q`

    - `P => (WP c Q)`
    
2. Use SMT Solver to Check VC is Valid

## Verification Strategy

1. Compute Verification Condition (VC)

    - `(SP P c) => Q`

    - `P => (WP c Q)`
    
2. Use SMT Solver to Check VC is Valid

### Problem: Pesky Loops

- Cannot compute `WP` or `SP` for `While b c` ...

- ... Require **invariants**


Next: Lets **infer** invariants by **approximation**


## Approximate Verification Strategy

0. Compute **Over-approximate** Postcondition `SP#` s.t.

    - `(SP P c) => (SP# P c)`

1. Compute Verification Condition (VC)

    - `(SP# P c) => Q`
    
2. Use SMT Solver to Check VC is Valid

    - If so, `{P} c {Q}` holds by **Consequence Rule** 

### Key Requirement 

- Compute `SP#` **without** computing `SP` ...

- But **guaranteeing** over-approximation


## What Makes Loops Special?

Why different from other constructs? Let 

- `c` be a loop-free (i.e. has no `While` inside it)

- `W` be the loop `While b c`


## Loops as Limits 

Inductively define the *infinite* sequence of loop-free `Com`

~~~~~{.haskell}
W_0   = Skip

W_1   = W_0 | Assume b; c; W_0

W_2   = W_1 | Assume b; c; W_1
.
.
.
W_i+1 = W_i | Assume b; c; W_i
.
.
.
~~~~~

## Loops as Limits 

Intuitively 

- `W_i` is the loop **unrolled upto** `i` times

- `W == W_0 | W_1 | W_2 | ...` 

Formally, we can prove (**exercise**)

~~~~~{.haskell}
1. eval s W  == eval s W_0 ++ eval s W_1 ++ ...

2. SP P W    == SP P W_0   || SP P W_1   || ...

3. WP W Q    == WP W_0 Q   && WP W_1 Q   && ...
~~~~~

So what? Still cannot **compute** `SP` or `WP` ...!

## Loops as Limits 

So what? Still cannot **compute** `SP` or `WP` ... but notice

~~~~~{.haskell}
SP P W_i+1 == SP P (W_i | assume b; c; W_i)
           
           == SP P W_i  || SP (SP P (assume b; c)) W_i

           <= SP P W_i 
~~~~~

That is, `SP P W_i` form an **increasing chain**

~~~~~{.haskell}
SP P W_0 => SP P W_1 => ... => SP P W_i => ...
~~~~~

... **Problem:** Chain does not converge! *ONION RINGS*

## Approximate Loops as Approximate Limits 

To find `SP#` such that `SP P c => SP# P c`, we compute chain

~~~~~{.haskell}
SP# P W_0 => SP# P W_1 => ... => SP# P W_i => ...
~~~~~

where each `SP#` is over-approximates the corresponding `SP`

~~~~~{.haskell}
for all i. SP P W_i => SP# P W_i
~~~~~

and the chain of `SP#` chain converges to a **fixpoint**

~~~~~{.haskell}
exists j. SP# P W_j+1 == SP# P W_j 
~~~~~

This magic `SP# P W_j+1` is the loop invariant, and 

~~~~~{.haskell}
SP# P W == SP# P W_j 
~~~~~

## Approximating Loops

### Many Questions Remain Around Our Strategy

How to compute `SP#` so that we can ensure 

1. **Convergence** to a fixpoint ? 

2. Result is an **over-approximation** of `SP` ?

### Answer: Abstract Interpretation

``Systematic basis for **approximating the semantics** of programs"

<!-- 
## TODO 

- AExp Syntax
- AExp Semantics
- AExp Abstract Semantics
- AExp Theorem
- AExp but how? [by induction on structure, yada]

- Lets formalize and generalize the recipe

- Conc vs Abs Value
- \alpha, \gamma 
- Pic
- Rephrase theorem
- Yes, but HOW? What if we had new operators?

- Systematic OP#

- Relate 
    op# x# y# = \alpha({x op y | x <- gamma(x#), y <- gamma(y#)})

- Picture

- Our first ABSINT

    Define 
        AbsValue
        ConcValue
        alpha 

    Get   
        Gamma
        Abstract Operators
        Abstract Semantics
        Soundness Theorem

- Our second ABSINT: + "UMINUS"

- Our third ABSINT: + "+"

- Value as CPO
    - \lub, \glb, \sqcup
    - Lift alpha to sets

- Our third ABSINT

    Define 
        AbsValue + CPO
        ConcValue
        alpha 

    Get   
        Gamma
        Alpha+SET
        Abstract Operators with LUB
        Abstract Semantics
        Soundness Theorem

STOP AT: Abstract Interpretation for IMP

-->


