% Abstract Interpretation
% Ranjit Jhala, UC San Diego
% April 22, 2013

## Fundamental Challenge of Program Analysis

**How to infer (loop) invariants** ?

### Classic Problem

- Key issue for any analysis or verification

- Many algorithms/heuristics

- See [Suzuki & Ishihata, POPL 1977](http://dl.acm.org/citation.cfm?id=512963)

- Most can be formalized in the framework of **Abstract Interpretation**

## Today: Abstract Interpretation

``A systematic basis for *approximating* the semantics of programs"

- Deep and broad area

- Rich theory, profound practical impact

- We look at a tiny slice: in context of algorithmic verification of **IMP**

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

### Transitions

**Transition relation** is a subset of `State` $\times$ `Com` $\times$ `State`

Formalized by `eval s c` which returns `[s' |` command `c` transitions state `s` to `s']`

~~~~~{.haskell}
eval                 :: State -> Com -> [State]
eval s (Assume e)    = if eval s e then [s] else []
eval s (x  :=  e)    = [ add x (eval s e) s ]
eval s (c1 ;  c2)    = [s'' | s' <- eval s c1, s'' <- eval s' c2]
eval s (c1 |  c2)    = eval s c1 ++ eval s c2
eval s w@(While e c) = eval s (Assume !e | (Assume e; c; w))  
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

- `SP P c` : Predicate describing states **reachable from** `P` by executing `c`

- `states (SP P c) == [s' | s <- states P, s' <- eval s c]`

### Weakest Precondition 

~~~~~{.haskell}
WP :: Com -> Pred -> Pred
~~~~~

- `WP c Q` : Predicate describing states that **can reach** `Q` by executing `c`

- `states (WP c Q)` = [s | s' <- eval s c, eval s' Q ]

## Strongest Postcondition 

- `SP P c` : Predicate describing states **reachable from** `P` by executing `c`

- `states (SP P c) == [s' | s <- states P, s' <- eval s c]`

~~~~~{.haskell}
SP                 :: Pred -> Com -> Pred

SP P (Assume e)    = P `&&` e

SP P (x := e)      = \exists x'. P[x'/x] `&&`  x `==` e[x'/x]

SP P (c1 ; c2)     = SP (SP P c1) c2 

SP P (c1 | c2)     = SP P c1 `||` SP p c2

SP P w@(While e c) = SP s (Assume !e | (Assume e; c; w))  
~~~~~

- **Uh Oh!** last case is non-terminating ...

## Weakest Precondition 

- `WP c Q` : Predicate describing states that **can reach** `Q` by executing `c`

- `states (WP c Q)` = [s | s' <- eval s c, eval s' Q ]

~~~~~{.haskell}
WP                 :: Com -> Pred -> Pred

WP (Assume e)    Q = e `=>` Q

WP (x := e)      Q = Q[e/x] 

WP (c1 ; c2)     Q = WP c1 (WP c2 Q) 

WP (c1 | c2)     Q = WP c1 Q `&&` WP c2 Q

WP w@(While e c) Q = WP (Assume !e | (Assume e; c; w)) Q
~~~~~

- **Uh Oh!** last case is non-terminating ...

## IMP: Verification 

(For a moment, suspend disbelief regarding loops)

### Goal: Verify Hoare-Triples

Given 

- `c` command
- `P` precondition 
- `Q` postcondition

Prove **Hoare-Triple** `{P} c {Q}` which denotes

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

- Lets **infer** invariants by **approximation**


## Approximate Verification Strategy

0. Compute **Over-approximate** Postcondition `SP#` s.t.

    - `SP P c` implies `SP# P c`

1. Compute Verification Condition (VC)

    - `(SP# P c) => Q`
    
2. Use SMT Solver to Check VC is Valid

    - If so, `{P} c {Q}` holds by **Consequence Rule** 

### Key Requirement 

- Compute `SP#` *without* computing `SP` ...

- But guaranteeing *over-approximation`

- How ?!!!

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
...
W_i+1 = W_i | Assume b; c; W_i
...
~~~~~

## Loops as Limits 

Intuitively 

- `W_i` is the loop **unrolled upto** `i` times

- `W == W_0 | W_1 | W_2 | ...` 

Formally, we can prove (**exercise**)

1. `eval s W  == eval s W_0 ++ eval s W_1 ++ eval s W_2 ++ ...`

2. `SP P W    == SP P W_0   || SP P W_1   || SP P W_2   || ...`

3. `WP W Q    == WP W_0 Q   && WP W_1 Q   && SP W_2 Q   && ...`

So what? Still cannot **compute** `SP` or `WP` ...!

## Loops as Limits 

So what? Still cannot **compute** `SP` or `WP` ...

... but notice that

~~~~~{.haskell}
SP P W_i+1 == SP P (W_i | assume b; c; W_i)
           
           == SP P W_i  || SP (SP P (assume b; c)) W_i
~~~~~

That is, `SP P W_i` form an **increasing chain**

~~~~~{.haskell}
SP P W_0 => SP P W_1 => SP P W_2 => ... => SP P W_i => ...
~~~~~

... **Problem** Chain does not converge! *ONION RINGS*

## Approximate Loops as Approximate Limits 

To compute `SP#` such that `SP P c => SP# P c`, we compute a chain

~~~~~{.haskell}
SP# P W_0 => SP# P W_1 => SP# P W_2 => ... => SP# P W_i => ...
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

- What is the `SP#` ?

- How to ensure **convergence** ?

- How to ensure **over-approximation** ?

### Answer: Abstract Interpretation

``A systematic basis for *approximating* the semantics of programs"

-------------------------------------------------------------------------------------------------
