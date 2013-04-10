% SMT: Satisfiability Modulo Theories 
% Ranjit Jhala, UC San Diego 
% April 9, 2013


## Decision Procedures 

### Last Time

- Propositional Logic

### Today 

1. **Combining** SAT *and Theory* Solvers

2. **Theory Solvers**
    
    - Theory of *Equality*
    - Theory of *Uninterpreted Functions*
    - Theory of *Difference-Bounded Arithmetic*

## Combining SAT and Theory Solvers

![SMT Solver Architecture](../static/smt-solver-empty.png)


## Combining SAT and Theory Solvers

**Goal** Determine if a formula `f` is *Satisfiable*.

~~~~~{.haskell}
data Formula = Prop PVar        -- ^ Prop Logic
             | And  [Formula]   -- ^ "" 
             | Or   [Formula]   -- ^ ""
             | Not  Formula     -- ^ ""
             | Atom Atom        -- ^ Theory Relation 
~~~~~

Where theory elements are described by

~~~~~{.haskell}
data Expr    = Var TVar | Con Int | Op  Operator [Expr]

data Atom    = Rel Relation [Expr]
~~~~~

## Split `Formula` into CNF + Theory Components

### CNF Formulas

~~~~~{.haskell}
data Literal    = Pos PVar | Neg PVar 
type Clause     = [Literal]
type CnfFormula = [Clause]
~~~~~

## Split `Formula` into CNF + Theory Components

### Theory Cube

A `TheoryCube` is an indexed list of `Atom`

~~~~~{.haskell}
data TheoryCube a  = [(a, Atom)]
~~~~~

### Theory Formula

A `TheoryFormula` is a `TheoryCube` indexed by `Literal`

~~~~~{.haskell}
type TheoryFormula = TheoryCube Literal 
~~~~~

- **Conjunction** of **assignments** of each literal to theory `Atom`

## Split `Formula` into CNF + Theory Components

### Split SMT Formulas 

An `SmtFormula` is a pair of `CnfFormula` and `TheoryFormula`

~~~~~{.haskell}
type SmtFormula    = (CnfFormula, TheoryFormula) 
~~~~~

**Theorem** There is a *poly-time* function 

~~~~~{.haskell}
toSmt :: Formula -> SmtFormula
toSmt = error "Exercise For The Reader"
~~~~~


## Split `SmtFormula` : Example 

Consider the formula

- $(a=b \vee a=c) \wedge (b=d \vee b=e) \wedge (c=d) \wedge (a \not = d) \wedge (a \not = e)$

We can split it into **CNF**

- $(x_1 \vee x_2) \wedge (x_3 \vee x_4) \wedge (x_5) \wedge (x_6) \wedge (x_7)$

And a **Theory Cube**

- $(x_1 \leftrightarrow a=b), (x_2 \leftrightarrow a=c), (x_3 \leftrightarrow b=d), (x_4 \leftrightarrow b=e)$ 
  $(x_5 \leftrightarrow c=d),(x_6 \leftrightarrow c=e),(x_6 \leftrightarrow a \not = d),(x_7 \leftrightarrow a \not = e)$

## Split `SmtFormula` : Example 

Consider the formula

- $(a=b \vee a=c) \wedge (b=d \vee b=e) \wedge (c=d) \wedge (a \not = d) \wedge (a \not = e)$

We can split it into a `CnfFormula`

~~~~~{.haskell}
( [[1, 2], [3, 4], [5], [6], [7]]
~~~~~

and a `TheoryFormula`

~~~~~{.haskell}
[ (1, Rel Eq ["a", "b"]), (2, Rel Eq ["a", "c"])
, (3, Rel Eq ["b", "d"]), (4, Rel Eq ["b", "e"])
, (5, Rel Eq ["c", "d"]) 
, (6, Rel Ne ["a", "d"]), (7, Rel Ne ["a", "e"]) ]
~~~~~

<!-- z_ -->

## Combining SAT and Theory Solvers: Architecture

![SMT Solver Architecture](../static/smt-solver-full.png)

## Combining SAT and Theory Solvers: Architecture

Lets see this in code

~~~~~{.haskell}
smtSolver :: Formula -> Result
smtSolver = smtLoop . toSmt 
~~~~~

## Combining SAT and Theory Solvers: Architecture

Lets see this in code

~~~~~{.haskell}
smtLoop   :: SmtFormula -> Result 
smtLoop (cnf, thy) =                     
  case satSolver cnf of
    UNSAT -> UNSAT
    SAT s -> case theorySolver $ cube thy s of
               SAT     -> SAT
               UNSAT c -> smtLoop (c:cnf) thy
~~~~~

Where, the function

~~~~~{.haskell}
cube :: TheoryFormula -> [Literal] -> TheoryFormula  
~~~~~

Returns a **conjunction of atoms** for the `theorySolver`


## Today 

1. Combining SAT *and Theory* Solvers

2. **Theory Solvers**
    
    - Theory of *Equality*
    - Theory of *Uninterpreted Functions*
    - Theory of *Difference-Bounded Arithmetic*

**Issue:** How to solve formulas over *different* theories?

## Need to Solve Formulas Over Different Theories

Input formulas `F` have `Relation`, `Operator` from *different* theories

- $F \equiv f(f(a) - f(b)) \not = f(c), b \geq a, c \geq b+c, c \geq 0$

- Recall here *comma* means *conjunction*

Formula contains symbols from 

- `EUF`   : $f(a)$, $f(b)$, $=$, $\not =$,...

- `Arith` : $\geq$, $+$, $0$,...

How to solve formulas over *different* theories?

## Naive Splitting Approach

Consider $F$ over $T_E$ (e.g. `EUF`) and $T_A$ (e.g. `Arith`)

### By Theory, Split $F$ Into $F_E \wedge F_A$ 

- $F_E$ which **only contains** symbols from $T_E$
- $F_A$ which **only contains** symbols from $T_A$

Our example,

- $F \equiv f(f(a) - f(b)) \not = f(c), b \geq a, c \geq b+c, c \geq 0$

Can be split into

- $F_E \equiv f(f(a) - f(b)) \not = f(c)$  <!-- _z -->
- $F_A \equiv b \geq a, c \geq b+c , c \geq 0$

## Naive Splitting Approach

Our example,

- $F \equiv f(f(a) - f(b)) \not = f(c) , b \geq a , c \geq b+c , c \geq 0$

Can be split into

- $F_E \equiv f(f(a) - f(b)) \not = f(c)$  <!-- _z -->
- $F_A \equiv b \geq a, c \geq b+c, c \geq 0$

**Problem! Pesky "minus" operator ($-$) has crept into $F_E$ ...**

## Less Naive Splitting Approach

**Problem! Pesky "minus" operator ($-$) has crept into $F_E$ ...**

### Name Sub-Expressions With Fresh Variables

- Replace $r(f(e)$ with $t = f(e) \wedge r(t)$

Example formula $F$ becomes 

- $t_1 = f(a),  t_2 = f(b), t_3 = t_1 - t_2$

- $f(t3) \not = f(c), b \geq a, c \geq b+c, c \geq 0$

Which splits nicely into

- $F_E \equiv t_1 = f(a),  t_2 = f(b), f(t3) \not = f(c)$

- $F_A \equiv t_3 = t_1 - t_2, b \geq a, c \geq b+c, c \geq 0$


## Less Naive Splitting Approach

Consider $F$ over $T_E$ (e.g. `EUF`) and $T_A$ (e.g. `Arith`)

- **Split** $F \equiv F_E \wedge F_A$

Now what? Run theory solvers independently 

~~~~~{.haskell}
theorySolver f =
  let (fE, fA) = splitByTheory f in 
  case theorySolverE fE, theorySolverA fA of
    (UNSAT, _) -> UNSAT
    (_, UNSAT) -> UNSAT 
    (SAT, SAT) -> SAT
~~~~~

**Will it work?**

## Less Naive Splitting Approach

### Run Theory Solvers Independently 

~~~~~{.haskell}
theorySolver f =
  let (fE, fA) = splitByTheory f in 
  case theorySolverE fE, theorySolverA fA of
    (UNSAT, _) -> UNSAT
    (_, UNSAT) -> UNSAT 
    (SAT, SAT) -> SAT
~~~~~

**Will it work? Alas, no.**

## Satisfiability of Mixed Theories

Consider $F$ over $T_E$ (e.g. `EUF`) and $T_A$ (e.g. `Arith`)

- **Split** $F \equiv F_E \wedge F_A$

The following are obvious 

1. *UNSAT* $F_E$ implies *UNSAT* $F_E \wedge F_A$ implies *UNSAT* $F$
2. *UNSAT* $F_A$ implies *UNSAT* $F_E \wedge F_A$ implies *UNSAT* $F$

But this **is not true**

3. *SAT* $F_E$ and *SAT $F_A$ implies *SAT* $F_E \wedge F_A$

## Satisfiability of Mixed Theories

*SAT* $F_E$ and *SAT* $F_A$ **does not imply** *SAT* $F_E \wedge F_A$

### Example

- $F_E \equiv t_1 = f(a),  t_2 = f(b), f(t3) \not = f(c)$

- $F_A \equiv t_3 = t_1 - t_2, b \geq a, c \geq b+c, c \geq 0$

### Individual Satisfying Assignment

- Let $\sigma \equiv = a \mapsto 0, b \mapsto 0, c \mapsto 1, f \mapsto \lambda x.x$ 

- Easy to check that $\sigma$ satisfies $F_E$ and $F_A$

- (But not both!)

*One* bad assignment doesn't mean $F$ is *UNSAT*...


## Proof of Unsatisfiability of Mixed Formula $F_E \wedge F_A$ 

!["Proof" Of Unsatisfiability](../static/smt-mixed-unsat-proof.png)





## Nelson-Oppen Framework For Combining Theory Solvers 

**TODO**

- Give example of NO
- Broadcast?
- Requirements (Convex)
- Example of NON-CONVEX


## Requirements of Theory Solvers

1. Broadcast Equalities
2. Broadcast "Proofs" / Slices ?

**TODO**


## Today 

1. Combining SAT *and Theory* Solvers

2. **Combining Solvers for Multiple Theories**
    
    - **Theory of Equality**
    - Theory of *Uninterpreted Functions*
    - Theory of *Difference-Bounded Arithmetic*

## Today 

1. Combining SAT *and Theory* Solvers

2. Combining Solvers for multiple theories
    
    - Theory of Equality
    - **Theory of Uninterpreted Functions**
    - Theory of *Difference-Bounded Arithmetic*

## Today 

1. Combining SAT *and Theory* Solvers

2. Combining Solvers for multiple theories

    - Theory of Equality
    - Theory of Uninterpreted Functions
    - **Theory of Difference-Bounded Arithmetic**

## Today 

1. Combining SAT *and Theory* Solvers

2. Combining Solvers for multiple theories

    - Theory of Equality
    - Theory of Uninterpreted Functions
    - Theory of Difference-Bounded Arithmetic

3. **Other Theories**
    - Lists
    - Arrays
    - Sets
    - Bitvectors 
    - ...


