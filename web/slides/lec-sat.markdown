% SAT Solvers 
% Ranjit Jhala, UC San Diego 
% April 9, 2013

## Decision Procedures

We will look very closely at the following

1. Propositional Logic
2. Theory of *Equality*
3. Theory of *Uninterpreted Functions*
4. Theory of *Difference-Bounded Arithmetic*

### Decision Problem: Satisfaction

- Does `eval s p` return `True`  for **some** assignment `s` ?

- *"Can we assign the variables to make the formula true"* ?


## Decision Procedures

We will look very closely at the following

1. Propositional Logic
2. Theory of *Equality*
3. Theory of *Uninterpreted Functions*
4. Theory of *Difference-Bounded Arithmetic*

### Why?

- Representative 
- Have *"efficient"* algorithms 

## Decision Procedures

We will look very closely at the following

1. Propositional Logic
2. Theory of *Equality*
3. Theory of *Uninterpreted Functions*
4. Theory of *Difference-Bounded Arithmetic*

### Plan 

- First in **isolation**
- Then in **combination**
- Very slick SW-Eng, based on logic 

## Decision Procedures: Propositional Logic

Popularly called **SAT Solvers**

## Decision Procedures: Propositional Logic

Basics 

- Propositional Logic 101
- Conjunctive Normal Form
- Resolution 

Algorithms

- Resolution 
- Backtracking Search
- Boolean Constraint Propagation
- Conflict Driven Learning & Backjumping

## Decision Procedures: Propositional Logic

Basics 

- **Propositional Logic 101**
- Conjunctive Normal Form
- Resolution 

Algorithms

- Resolution 
- Backtracking Search
- Boolean Constraint Propagation
- Conflict Driven Learning & Backjumping


## Propositional Logic 101

### Propositional Variables

~~~~~{.haskell}
data PVar 
~~~~~

### Propositional Formulas

~~~~~{.haskell}
data Formula = Prop PVar
             | Not  Formula
             | Formula `And` Formula
             | Formula `Or`  Formula
~~~~~

## Decision Procedures: Propositional Logic

Basics 

- Propositional Logic 101
- **Conjunctive Normal Form**
- Resolution

Algorithms

- Resolution 
- Backtracking Search
- Boolean Constraint Propagation
- Conflict Driven Learning & Backjumping

## Conjunctive Normal Form

**Restricted** representation of `Formula` 

### Literals: Variables or Negated Variables

~~~~~{.haskell}
data Literal    = Pos PVar | Neg PVar 
~~~~~

### Clauses: Disjunctions (Or) of Literals

~~~~~{.haskell}
data Clauses    = [Literal]
~~~~~

### CNF Formulas: Conjunctions (And) of Clauses 

~~~~~{.haskell}
data CnfFormula = [Clauses]
~~~~~

## Conjunctive Normal Form: Example

### Consider a Formula  

$(x_1 \vee x_2) \wedge (\neg x_1 \vee x_3) \wedge \neg x_3$

<!-- z_ -->

### Represented as a `Formula`

~~~~~{.haskell}
      (Prop 1       `Or` Prop 2) 
`And` (Not (Prop 1) `Or` Prop 3) 
`And` (Not (Prop 3)            )
~~~~~

### Represented as a `CnfFormula`

~~~~~{.haskell}
     [ [Pos 1 , Pos 2]
     , [Neg 1 , Pos 3]
     , [Neg 3        ] ]
~~~~~

## Conjunctive Normal Form Conversion

**Theorem** There is a *poly-time* function 

~~~~~{.haskell}
toCNF :: Formula -> CnfFormula
toCNF = error "Exercise For The Reader"
~~~~~

Such that any `f` is satisfiable *iff* `(toCNF f)` is satisfiable.

- `toCNF` adds **new variables** for sub-formulas

- otherwise, an **exponential blowup** in `CnfFormula` size

## Conjunctive Normal Form Conversion

**Theorem** There is a *poly-time* function 

~~~~~{.haskell}
toCNF :: Formula -> CnfFormula
toCNF = error "Exercise For The Reader"
~~~~~

Such that any `f` is satisfiable *iff* `(toCNF f)` is satisfiable.

**Henceforth** Only consider formulas in Conjunctive Normal Form Formulas

## Decision Procedures: Propositional Logic

Basics 

- Propositional Logic 101
- Conjunctive Normal Form

Algorithms

- **Resolution** 
- Backtracking Search
- Boolean Constraint Propagation
- Conflict Driven Learning & Backjumping

## Properties of CNF

### Pure Variable

- One which appears only $+ve$ or $-ve$ in a `CnfFormula`

### Empty Clause

- **If** a `CnfFormula` has *some* `Clause` without `Literals` 
- **Then** the `CnfFormula` is **UNSAT**

### Trivial Formula

- **If** a `CnfFormula` has *no* `Clause` 
- **Or** every variable is *pure*   
- **Then** the `CnfFormula` is **SAT**

## Goal

Determine satisfaction by **reducing** `CnfFormula` to one of

- Empty Clause  (ie *UNSAT*), or

- Trivial Formula (ie *SAT*).

## Reducing Formulas By Resolution

("Reduce" is, perhaps, not the best word...)

**Resolution:** For any $A,B$ and variable $x$, the formula

$$(A \vee x) \wedge (B \vee \neg x)$$

is *equivalent to* the formula

$$(A \vee B)$$

- The variable $x$ is called a **pivot** variable

## General Resolution

**Resolution:** For any $A_i,B_j$ and variable $x$, the formula

$$\bigwedge_i (A_i \vee x) \wedge \bigwedge_j (B_j \vee \neg x)$$

is *equivalent to* the formula

$$\bigwedge_{i,j} (A_i \vee B_j)$$

<!-- _z -->

- Pivot variable $x$ is **eliminated** by resolution

## Davis-Putnam Algorithm: Example 1

Input Formula

- $(x_1 \vee x_2 \vee x_3) \wedge (x_2 \vee \neg x_3 \vee x_5) \wedge (\neg x_2 \vee x_4))$

Pivot on $x_2$

- $(x_1 \vee x_3 \vee x_4) \wedge (\neg x_3 \vee x_5 \vee x_4)$

Pivot on $x_3$

- $(x_1 \vee x_4 \vee x_5)$

<!-- _z -->

All variables are *pure* ... hence, **SAT** 

## Davis-Putnam Algorithm: Example 2 

Input Formula

- $(x_1 \vee x_2) \wedge (x_1 \vee \neg x_2) \wedge (\neg x_1 \vee x_3) \wedge (\neg x_1 \vee \neg x_3)$

Pivot on $x_2$

- $(x_1) \wedge (\neg x_1 \vee x_3) \wedge (\neg x_1 \vee \neg x_3)$

Pivot on $x_3$

- $(x_1) \wedge (\neg x_1)$
 
Pivot on $x_1$

- $()$

*Empty clause* ... hence, **UNSAT**

## Davis-Putnam Algorithm

### Algorithm

1. Select **pivot** and perform **resolution** 
2. Repeat until **SAT** or **UNSAT**

### Issues?

- Space blowup (formula size blows up on resolution)


## Decision Procedures: Propositional Logic

Basics 

- Propositional Logic 101
- Conjunctive Normal Form

Algorithms

- Resolution 
- **Backtracking Search**
- Boolean Constraint Propagation
- Conflict Driven Learning & Backjumping

## Decision Tree: Describes Space of All Assignments

![SAT Decision Tree (Courtesy: Lintao Zhang)](../static/sat-tree-full-small.png "Decision Tree")

## Decision Tree: SAT via Depth First Search 

![DFS On Decision Tree (Courtesy: Lintao Zhang)](../static/sat-tree-full-solution-small.png "Decision Tree")

## Backtracking Search 

Don't build *whole* tree, but lazily search solutions

- **Choose**    a variable $x$, set to `True`
- **Remove**    constraints where $x$ appears
- **Recurse**   on remaining constraints
- **Backtrack** if a contradiction is found

## Backtracking Search (1/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-1-small.png)


## Backtracking Search (2/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-2-small.png)

## Backtracking Search (3/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-3-small.png)

## Backtracking Search (4/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-4-small.png)

## Backtracking Search (5/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-5-small.png)

## Backtracking Search (6/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-6-small.png)

## Backtracking Search (7/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-7-small.png)

## Backtracking Search (8/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-8-small.png)

## Backtracking Search (9/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-9-small.png)

## Backtracking Search (10/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-10-small.png)

## Backtracking Search (11/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-11-small.png)

## Backtracking Search (12/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-12-small.png)

## Backtracking Search (13/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-13-small.png)

## Backtracking Search (14/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-14-small.png)

## Backtracking Search (15/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-15-small.png)

## Backtracking Search (16/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-16-small.png)

## Backtracking Search (17/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-17-small.png)

## Backtracking Search (18/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-18-small.png)

## Backtracking Search (19/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-19-small.png)

## Backtracking Search (20/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-20-small.png)

## Backtracking Search (21/21) 

![Basic DLL (Courtesy: Lintao Zhang)](../static/sat-dll-21-small.png)


## Backtracking Search

Don't build *whole* tree, but lazily search solutions

- **Choose**    a variable $x$, set to `True`
- **Remove**    constraints where $x$ appears
- **Recurse**   on remaining constraints
- **Backtrack** if a contradiction is found

(*whew!*)

- DFS avoids *space* blowup (only need to save stack) ...
- ... but not time (natch)

## Decision Procedures: Propositional Logic

Basics 

- Propositional Logic 101
- Conjunctive Normal Form

Algorithms

- Resolution 
- Backtracking Search
- **Boolean Constraint Propagation**
- Conflict Driven Learning & Backjumping

## Boolean Constraint Propagation

Often, we don't really have a choice...

## Boolean Constraint Propagation

### Unit Clause Rule

- **If** an (unsatisfied) `Clause` has **one** unassigned `Literal`
- **Then** that `Literal` **must** be `True` in any SAT assignment

### Example

- **Formula** $(x_1 \vee \neg x_2 \vee x_3) \wedge (x_2 \vee \neg x_3) \wedge (\neg x_1 \vee \neg x_3)$ 

- **Assignment** $x_1 = T, x_2 = T$

- The **last** clause is a unit clause

- Any SAT assigment **must** set $\neg x_3 = T$ (i.e. $x_3 = F$)

## Boolean Constraint Propagation

### Unit Clause Rule

- **If** an (unsatisfied) `Clause` has **one** unassigned `Literal`
- **Then** that `Literal` **must** be `True` in any SAT assignment

### BCP or Unit Propagation

- **Repeat** applying *unit clause rule*
- **Until** no unit clause remains.  

## Boolean Constraint Propagation: Example

Revisit Example With BCP

![Boolean Constraint Propagation (Courtesy: Lintao Zhang)](../static/sat-dll-21-small.png)

## Boolean Constraint Propagation

### DPLL = Backtracking Search + BCP 

- Backtracking: Avoids space blowup

- BCP: Avoid doing obvious work

- Still repeatedly explore all choices (e.g. whole left subtree)

### Wanted

- Means to *learn* to repeat *dead ends* 

- Key to scaling to practical problems


## Decision Procedures: Propositional Logic

Basics 

- Propositional Logic 101
- Conjunctive Normal Form

Algorithms

- Resolution 
- Backtracking Search
- Boolean Constraint Propagation
- **Conflict Driven Learning & Backjumping**

## Conflict Driven Learning

<!-- _z -->

### Key Insight

- On finding conflict, don't (just) backtrack

- **Learn new clause** to prevent same conflict in future

### Major breakthrough

- J. P. Marques-Silva and K. A. Sakallah, "GRASP -- A New Search 
Algorithm for Satisfiability," Proc. ICCAD 1996. 

- R. J. Bayardo Jr. and R. C. Schrag "Using CSP look-back techniques to 
solve real world SAT instances." Proc. AAAI, 1997

## Conflict Driven Learning

- Resolve on conflict variable to **learn** new **conflict** clause

- **Add** clause to set of clauses

- **Backjump** using conflict clause

## Conflict Driven Learning

Revisit Example With CDL

- Learn, Add, Backjump
- Vastly faster search

![Boolean Constraint Propagation (Courtesy: Lintao Zhang)](../static/sat-dll-21-small.png)

## Backtracking Only (01/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-01.png)

## Backtracking Only (02/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-02.png)

## Backtracking Only (03/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-03.png)

## Backtracking Only (04/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-04.png)

## Backtracking Only (05/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-05.png)

## Backtracking Only (06/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-06.png)

## Backtracking Only (07/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-07.png)

## Backtracking Only (08/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-08.png)

## Backtracking Only (09/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-09.png)

## Backtracking Only (10/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-10.png)

## Backtracking Only (11/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-11.png)

## Backtracking Only (12/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-12.png)

## Backtracking Only (13/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-13.png)

## Backtracking Only (14/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-14.png)

## Backtracking Only (15/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-15.png)

## Backtracking Only (16/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-16.png)

## Backtracking Only (17/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-17.png)

## Backtracking Only (18/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-18.png)

## Backtracking Only (19/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-19.png)

## Backtracking Only (20/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-20.png)

## Backtracking Only (21/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-21.png)

## Backtracking Only (22/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-22.png)

## Backtracking Only (23/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-23.png)

## Backtracking Only (24/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-24.png)

## Backtracking Only (25/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-25.png)

## Backtracking Only (26/26)

![Backtracking Only](../static/alan/Backtracking/Backtracking-26.png)

## Boolean Constraint Propagation (01/23)

![BCP](../static/alan/BCP/BCP-01.png)

## Boolean Constraint Propagation (02/23)

![BCP](../static/alan/BCP/BCP-02.png)

## Boolean Constraint Propagation (03/23)

![BCP](../static/alan/BCP/BCP-03.png)

## Boolean Constraint Propagation (04/23)

![BCP](../static/alan/BCP/BCP-04.png)

## Boolean Constraint Propagation (05/23)

![BCP](../static/alan/BCP/BCP-05.png)

## Boolean Constraint Propagation (06/23)

![BCP](../static/alan/BCP/BCP-06.png)

## Boolean Constraint Propagation (07/23)

![BCP](../static/alan/BCP/BCP-07.png)

## Boolean Constraint Propagation (08/23)

![BCP](../static/alan/BCP/BCP-08.png)

## Boolean Constraint Propagation (09/23)

![BCP](../static/alan/BCP/BCP-09.png)

## Boolean Constraint Propagation (10/23)

![BCP](../static/alan/BCP/BCP-10.png)

## Boolean Constraint Propagation (11/23)

![BCP](../static/alan/BCP/BCP-11.png)

## Boolean Constraint Propagation (12/23)

![BCP](../static/alan/BCP/BCP-12.png)

## Boolean Constraint Propagation (13/23)

![BCP](../static/alan/BCP/BCP-13.png)

## Boolean Constraint Propagation (14/23)

![BCP](../static/alan/BCP/BCP-14.png)

## Boolean Constraint Propagation (15/23)

![BCP](../static/alan/BCP/BCP-15.png)

## Boolean Constraint Propagation (16/23)

![BCP](../static/alan/BCP/BCP-16.png)

## Boolean Constraint Propagation (17/23)

![BCP](../static/alan/BCP/BCP-17.png)

## Boolean Constraint Propagation (18/23)

![BCP](../static/alan/BCP/BCP-18.png)

## Boolean Constraint Propagation (19/23)

![BCP](../static/alan/BCP/BCP-19.png)

## Boolean Constraint Propagation (20/23)

![BCP](../static/alan/BCP/BCP-20.png)

## Boolean Constraint Propagation (21/23)

![BCP](../static/alan/BCP/BCP-21.png)

## Boolean Constraint Propagation (22/23)

![BCP](../static/alan/BCP/BCP-22.png)

## Boolean Constraint Propagation (23/23)

![BCP](../static/alan/BCP/BCP-23.png)

## Conflict Driven Learning (01/21)

![CDL](../static/alan/CDL/CDL-01.png)

## Conflict Driven Learning (02/21)

![CDL](../static/alan/CDL/CDL-02.png)

## Conflict Driven Learning (03/21)

![CDL](../static/alan/CDL/CDL-03.png)

## Conflict Driven Learning (04/21)

![CDL](../static/alan/CDL/CDL-04.png)

## Conflict Driven Learning (05/21)

![CDL](../static/alan/CDL/CDL-05.png)

## Conflict Driven Learning (06/21)

![CDL](../static/alan/CDL/CDL-06.png)

## Conflict Driven Learning (07/21)

![CDL](../static/alan/CDL/CDL-07.png)

## Conflict Driven Learning (08/21)

![CDL](../static/alan/CDL/CDL-08.png)

## Conflict Driven Learning (09/21)

![CDL](../static/alan/CDL/CDL-09.png)

## Conflict Driven Learning (10/21)

![CDL](../static/alan/CDL/CDL-10.png)

## Conflict Driven Learning (11/21)

![CDL](../static/alan/CDL/CDL-11.png)

## Conflict Driven Learning (12/21)

![CDL](../static/alan/CDL/CDL-12.png)

## Conflict Driven Learning (13/21)

![CDL](../static/alan/CDL/CDL-13.png)

## Conflict Driven Learning (14/21)

![CDL](../static/alan/CDL/CDL-14.png)

## Conflict Driven Learning (15/21)

![CDL](../static/alan/CDL/CDL-15.png)

## Conflict Driven Learning (16/21)

![CDL](../static/alan/CDL/CDL-16.png)

## Conflict Driven Learning (17/21)

![CDL](../static/alan/CDL/CDL-17.png)

## Conflict Driven Learning (18/21)

![CDL](../static/alan/CDL/CDL-18.png)

## Conflict Driven Learning (19/21)

![CDL](../static/alan/CDL/CDL-19.png)

## Conflict Driven Learning (20/21)

![CDL](../static/alan/CDL/CDL-20.png)

## Conflict Driven Learning (21/21)

![CDL](../static/alan/CDL/CDL-21.png)


## More Details about SAT Solvers

Lectures By Lintao Zhang (ZChaff)

- [1](http://research.microsoft.com/en-us/people/lintaoz/sat_course1.pdf)
- [2](http://research.microsoft.com/en-us/people/lintaoz/sat_course2.pdf)

## Next Time: SMT = SAT + Theories 

1. Propositional Logic

2. Combining Theories
    - *Equality + Uninterpreted Functions*
    - *Difference-Bounded Arithmetic*

3. Combining SAT + Theories
