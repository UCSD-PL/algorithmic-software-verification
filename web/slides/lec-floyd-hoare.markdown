% Floyd-Hoare Logic
% Ranjit Jhala, UC San Diego
% April 16, 2013

## Reasoning about imperative programs

### IMP: Syntax

* Commands: C ::= skip | x := e | while B do C | C1; C2 | if B then C1 else C2

* Arithmetic expressions: E ::= 0, 1, ... | x, y, ... | E1 op E2

  * where op ∈ { +, *, - }

* Boolean expressions: B ::= true | false | E1 = E2 | E1 < E2 | B1 && B2 | B1 || B2 | !B1 | B1 => B2

### IMP: Operational semantics

* Define a state σ : Vars → Int

* Define an evaluation judgement for expressions as a relation <e,σ>⇓n

  * "In state σ, expression e evaluates to n"

* Define an evaluation judgement for commands as a relation <c,σ>⇓σ'

  * "In state σ, executing command c takes the system into state σ'"

### Reasoning with operational semantics

It is painful to prove properties of a particular execution using operational
semantics.

## Axiomatic semantics

Use Hoare triples of a precondition P, a command c, and a postcondition Q

### Partial correctness

* { P } c { Q }

* "In a state where P holds, if running command c terminates, then it yields a
state where Q holds"

* ∀σ. <σ,P>⇓true → ∀σ'. <σ,c>⇓σ' → <σ,Q>⇓true

### Total correctness

* [ P ] c [ Q ]

* "In a state where P holds, running command c terminates and yields a state
where Q holds"

* ∀σ. <σ,P>⇓true → ∃σ'. <σ,c>⇓σ' → <σ,Q>⇓true

### Derivation rules

$$\frac{}{ ⊢ \{ P \} skip \{ P \} }$$

$$\frac{ ⊢ \{ P \} c1 \{ Q \} \quad ⊢ \{ Q \} c2 \{ R \} }{ ⊢ \{ P \} c1; c2 \{ R \} }$$

$$\frac{ ⊢ \{ P && b \} c1 \{ Q \} \quad ⊢ \{ P && !b \} c2 \{ Q \} }{ ⊢ \{ P \} if b then c1 else c2 \{ Q \} }$$

For the assignment, you can have a rule to go forward:

$$\frac{}{ ⊢ \{ P \} x := e \{ ∃ x_{old}. P [ x_{old} / x ] \wedge x = e [ x_{old} / x ] \} }$$

or backward:

$$\frac{}{ ⊢ \{ Q [ e / x ] \} x := e \{ Q \} }$$

For the while loop, a not so useful way would be to define it as while b c :=
if b then (c; while b c) else skip, however this gives a recursive rule that is
not so useful. Instead, we exhibit a loop invariant:

$$\frac{ ⊢ \{ I && b \} c \{ I \} }{ ⊢ \{ I \} while b do c \{ I && !b \} }$$

