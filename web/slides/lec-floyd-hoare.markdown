% Floyd-Hoare Logic
% Ranjit Jhala, UC San Diego
% April 16, 2013

## IMP: Syntax

* Commands

    C ::= skip | x := E | while B do C | C1; C2 | if B then C1 else C2

* Arithmetic expressions:

    E ::= 0, 1, ... | x, y, ... | E1 op E2

    * where $\text{op} \in \{ +, *, - \}$

* Boolean expressions:

    B ::= true | false | E1 = E2 | E1 < E2 | B1 \&\& B2 | B1 || B2 | !B1 | B1 => B2

## IMP: Operational semantics

* Define a state $\sigma : Vars \rightarrow Int$

* Define an evaluation judgement for expressions as a relation $<e, \sigma> \Downarrow n$

    * "In state $\sigma$, expression e evaluates to n"

* Define an evaluation judgement for commands as a relation $<c, \sigma> \Downarrow \sigma\prime$

    * "In state $\sigma$, executing command c takes the system into state $\sigma\prime$"

## IMP: Operational semantics (arithmetic expressions)

$$\frac{  }{ <n, \sigma> \Downarrow n }$$

$$\frac{  }{ <x, \sigma> \Downarrow \sigma(x) }$$

$$\frac{ <e1, \sigma> \Downarrow n1 \quad <e2, \sigma> \Downarrow n2 }{ <e1 \  \text{op} \  e2, \sigma> \Downarrow n1 \  \text{op} \  n2 }$$

* where $\text{op} \in \{ +, *, - \}$

## IMP: Operational semantics (boolean expressions)

$$\frac{  }{ <\text{true}, \sigma> \Downarrow \text{true} }$$

$$\frac{  }{ <\text{false}, \sigma> \Downarrow \text{false} }$$

$$\frac{ <e1, \sigma> \Downarrow n1 \quad <e2, \sigma> \Downarrow n2 \quad n1 \ \text{op} \  n2 \text{ is true} }{ <e1 \  \text{op} \  e2, \sigma> \Downarrow \text{true} }$$

$$\frac{ <e1, \sigma> \Downarrow n1 \quad <e2, \sigma> \Downarrow n2 \quad n1 \ \text{op} \  n2 \text{ is false} }{ <e1 \  \text{op} \  e2, \sigma> \Downarrow \text{false} }$$

* where $\text{op} \in \{ =, < \}$

## IMP: Operational semantics (boolean expressions)

$$\frac{ <b1, \sigma> \Downarrow b1 \quad <b2, \sigma> \Downarrow p2 }{ <e1 \  \text{op} \  e2, \sigma> \Downarrow p1 \  \text{op} \ p2 }$$

* where $\text{op} \in \{ \&\&, || \}$

$$\frac{ <b, \sigma> \Downarrow p }{ < ! b, \sigma> \Downarrow ! p }$$

## IMP: Operational semantics (commands)

$$\frac{  }{ <\text{skip}, \sigma> \Downarrow \sigma }$$

$$\frac{ <c1, \sigma> \Downarrow \sigma\prime \quad <c2, \sigma\prime> \Downarrow \sigma\prime\prime }{ <c1 ; c2, \sigma> \Downarrow \sigma\prime\prime }$$

$$\frac{ <b1, \sigma> \Downarrow b1 \quad <b2, \sigma> \Downarrow p2 }{ <e1 \  \text{op} \  e2, \sigma> \Downarrow p1 \  \text{op} \ p2 }$$

## Reasoning with operational semantics

It is painful to prove properties of a particular execution using operational
semantics.

## Axiomatic semantics

Use Hoare triples of a precondition P, a command c, and a postcondition Q

### Partial correctness

* { P } c { Q }

* "In a state where P holds, if running command c terminates, then it yields a
state where Q holds"

* $\forall \sigma. <\sigma, P> \Downarrow true \rightarrow \forall \sigma\prime. <\sigma, c> \Downarrow \sigma\prime \rightarrow <\sigma\prime, Q> \Downarrow true$

### Total correctness

* [ P ] c [ Q ]

* "In a state where P holds, running command c terminates and yields a state
where Q holds"

* $\forall \sigma. <\sigma, P> \Downarrow true \rightarrow \exists \sigma\prime. <\sigma, c> \Downarrow \sigma\prime \rightarrow <\sigma\prime, Q> \Downarrow true$

## Derivation rules

$$\frac{}{ \vdash \{ P \} \text{ skip } \{ P \} }$$

$$\frac{ \vdash \{ P \} \text{ c1 } \{ Q \} \quad \vdash \{ Q \} \text{ c2 } \{ R \} }{ \vdash \{ P \} \text{ c1; c2 } \{ R \} }$$

$$\frac{ \vdash \{ P \  \&\& \  b \} \text{ c1 } \{ Q \} \quad \vdash \{ P \  \&\& \  !b \} \text{ c2 } \{ Q \} }{ \vdash \{ P \} \text{ if b then c1 else c2 } \{ Q \} }$$

## Derivation rules

For the assignment, you can have a rule to go forward:

$$\frac{}{ \vdash \{ P \} \text{ x := e } \{ \exists x_{old}. P [ x_{old} / x ] \wedge x = e [ x_{old} / x ] \} }$$

or backward:

$$\frac{}{ \vdash \{ Q [ e / x ] \} \text{ x := e } \{ Q \} }$$

## Derivation rules

For the while loop, a not so useful way would be to define it as:

    while b do c := if b then (c; while b c) else skip

However this gives a recursive rule that is not so useful. Instead, we exhibit
a loop invariant:

$$\frac{ \vdash \{ I \  \&\& \  b \} c \{ I \} }{ \vdash \{ I \} \text{ while b do c } \{ I \  \&\& \  !b \} }$$

## While example

Take as an example

    { x = 0 } while x <= 5 do x := x + 1 { x = 6 }

Recalling the rule for while loops, 

$$\frac{ \vdash \{ I \  \&\& \  b \} c \{ I \} }{ \vdash \{ I \} \text{ while b do c } \{ I \  \&\& \  !b \} }$$

we need to "guess" a suitable invariant, I.

## While example (loop invariants)

It is easy to show that I = `x <= 6` works, since we can clearly prove

$$
\{ \text{x $\leq$ 5 \&\& x $\leq$ 6} \} \text{ x := x + 1 } \{ \text{x $\leq$ 6} \}
$$

as required. Taking the following

$$
\text{x $=$ 0} \Rightarrow \text{x $\leq$ 5} \text{ and } \text{x $\leq$ 6 \&\& x $>$ 5} \Rightarrow \text{x $=$ 6}
$$

with the rule of consequence gives us the desired

$$ \{ \text{x $=$ 0} \} \text{ while x $\leq$ 5 x := x + 1 } \{ \text{x $=$ 6} \} $$

## Automation

Carrying out these proofs is a fairly mechanical process. But:

+ How do we check implications (rule of consequence)?
+ How do we determine suitable loop invariants?
+ When do we apply the rule of consequence?

## Automation

+ How do we check implications (rule of consequence)?

  We can use SMT solvers to discharge proof obligations.

+ How do we determine suitable loop invariants?

  Assume these are given, for now.

+ When do we apply the rule of consequence?

  By computing "Weakest Preconditions" (or "Strongest Postconditions").
  
## Weakest Preconditions

Given c and Q, for the triple we want to answer what is the *biggest* P such that
{ P } c { Q } holds.

This is the *Weakest Precondition* of c with respect to Q, written WP(c, Q).

Thus, if for some P, P $\Rightarrow$ WP(c, Q), then { P } c { Q }.

To prove { P } c1; c2; c3; { Q }, check: $$\text{P} \Rightarrow \text{WP(c1, WP(c2, WP(c3, Q)))}$$.

## Computing Weakest Preconditions

Weakest Preconditions are computed axiomatically:

+ WP(`skip`, Q) = Q
+ WP(`x := e`, Q) = Q[e/x]
+ WP(`c1;c2`, Q) = WP(`c1`, WP(`c2`, Q))
+ WP(`if b m n`, Q) = `b` $\Rightarrow$ WP(`m`, Q) && `!b` $\Rightarrow$ WP(`n`, Q)
+ WP(`while`$_\text{I}$ `b c`, Q) = I, with side conditions:
    + I && b $\Rightarrow$ WP(`c`, I)
    + I && !b $\Rightarrow$ Q
    
## Language Extension

* Commands

    C ::= ... assert(P) | assume(P)

* `assert` causes the program to enter a "crash" state if its argument does not hold

* `assume` causes the program to loop forever if its argument does not hold

## Assert and Assume
* Semantics

$$\frac{ <\sigma,p> \Downarrow false }{ <\sigma, \text{assert}(p)> \Downarrow \text{crash} }$$

$$\frac{ <\sigma,p> \Downarrow true }{ <\sigma, \text{assert}(p)> \Downarrow \sigma` }$$

$$\frac{ <\sigma,p> \Downarrow true }{ <\sigma, \text{assume}(p)> \Downarrow \sigma` }$$

* WP(`assume(P)`, Q) = P $\Rightarrow$ Q
* WP(`assert(P)`, Q) = P && Q

## Functions with Assert \& Assume

* Each function `f(x)` is annotated with a precondition $P_f$ and postcondition $Q_f$

* Model a call to `f(x)`:

    `f(e)` $\Leftrightarrow$ `assert(`$P_f$[`e`/`x`]`); assume(`$Q_f$[`e`/`x`]`);` 




