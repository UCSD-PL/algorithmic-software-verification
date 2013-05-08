% Abstract Interpretation - Theory 
% Ranjit Jhala, UC San Diego
% April 30, 2013



## IMP: A Small Imperative Language

Recall the syntax of IMP

~~~~~{.haskell}
data Com = Var `:=` Expr            -- assignment
         | Com `;`  Com             -- sequencing
         | Assume   Exp             -- assume 
         | Com `|`  com             -- branch
         | While Pred Exp Com       -- loop
~~~~~

An alternative way to represent programs in IMP is using **Flow-charts**:

![](figs/flow-charts.svg)

What are the semantics of a program in the form of a flow-chart?

State of a program point is a mapping from variables to values: $\Sigma = Vars \mapsto Value$

## Concrete Semantics ("Collecting Semantics")

Each program point has a label. The set of all states that can be reached at a
label is called the **collecting semantics**. 

**Definition.** $K_i$ : the set of states that are visible from label $i$.

What follows is the definition of collecting semantics at different labels.

### For the single assignment:

![](figs/assign.svg)

There are two ways to express $K_j$ in terms of $K_i$:

1. $K_j = \{\sigma\left[\text{x}\mapsto\sigma\left[\text{e}\right]\right] | \sigma \in K_i\}$

2. $K_j \supseteq SP(K_i, \text{x:=e}) \implies K_j \supseteq K_i[\text{x}_0/\text{x}] \wedge \text{x} = \text{e}[\text{x}/\text{x}_0]$

### For the if branch:

![](figs/if.svg)


$K_l \supseteq K_i \cap \{\rho\} \qquad\qquad\qquad K_m\supseteq K_i \cap \{\neg\rho\}$ 


### For the join statement:

![](figs/join.svg)

$K_l \supseteq K_i \wedge K_l\supseteq K_j$ 


## Example:

~~~~~{.javascript}
var x = nonNeg();
var y = 1;
while(x > 0) {
  y = y * x;
  x = x - 1;
}
~~~~~

![](figs/example.svg)

The states at every point in the flow chart above satisfy the following constraints:

- $K_{.0} \supseteq \{\text{x} > 0\}$
- $k_{.1} \supseteq K_{.0}[\text{y}_0/\text{y}] \wedge \text{y} = 1$
- $K_{.2} \supseteq K_{.1} \wedge K_{.2} \supseteq K_{.5}$
- $k_{.3} \supseteq K_{.2} \cap \{\text{x} > 0\}$
- $k_{.4} \supseteq K_{.3}[\text{y}_0/\text{y}] \wedge \text{y} = \text{y}_0 * x$
- $k_{.5} \supseteq K_{.3}[\text{x}_0/\text{x}] \wedge \text{x} = \text{x}_0 - 1$
- $k_{.6} \supseteq K_{.2} \cap \{\text{x} \leq 0\}$

The *collecting semantics* is the smallest set of $K_i$'s such that the above
constrainst are satisfied. $K_i$'s belong to the range of a function $K:: Labels
\mapsto 2^{\Sigma}$, so the above constraints can be summarized in the
following: $K \supseteq F(K)$, where $F$ is a function from the current states
to the next ones. Our goal is to compute the smallest map $K$, for which this
constraint holds. We note that inclusion between two maps $K \subseteq K'$ means 
that $\forall l\ K.l \subseteq K'.l$.

A simple algorithm to compute this is the following:

~~~~~{.javascript}
K = \l -> {}
do
  K_old = K;
  K = F(K_old);
until (K == K_old)
~~~~~

When the above procedure ends, we get a fixed-point: $K^* = F(K^*)$. $K^*$ is the 
collecting semantics for this program.


