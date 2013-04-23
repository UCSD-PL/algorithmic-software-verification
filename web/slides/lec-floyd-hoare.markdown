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

* Define an evaluation judgement for commands as a relation $<c, \sigma> \Downarrow \sigma'$

    * "In state $\sigma$, executing command c takes the system into state $\sigma'$"

## Reasoning with operational semantics

It is painful to prove properties of a particular execution using operational
semantics.

## Axiomatic semantics

Use Hoare triples of a precondition P, a command c, and a postcondition Q

### Partial correctness

* { P } c { Q }

* "In a state where P holds, if running command c terminates, then it yields a
state where Q holds"

* $\forall \sigma. <\sigma, P> \Downarrow true \rightarrow \forall \sigma'. <\sigma, c> \Downarrow \sigma' \rightarrow <\sigma', Q> \Downarrow true$

### Total correctness

* [ P ] c [ Q ]

* "In a state where P holds, running command c terminates and yields a state
where Q holds"

* $\forall \sigma. <\sigma, P> \Downarrow true \rightarrow \exists \sigma'. <\sigma, c> \Downarrow \sigma' \rightarrow <\sigma', Q> \Downarrow true$

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

