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


### Concrete Semantics

The states at every point in the flow chart above satisfy the following constraints:

* $K_{.0} \supseteq \{\text{x} > 0\}$
* $k_{.1} \supseteq K_{.0}[\text{y}_0/\text{y}] \wedge \text{y} = 1$
* $K_{.2} \supseteq K_{.1} \wedge K_{.2} \supseteq K_{.5}$
* $k_{.3} \supseteq K_{.2} \cap \{\text{x} > 0\}$
* $k_{.4} \supseteq K_{.3}[\text{y}_0/\text{y}] \wedge \text{y} = \text{y}_0 * \text{x}$
* $k_{.5} \supseteq K_{.3}[\text{x}_0/\text{x}] \wedge \text{x} = \text{x}_0 - 1$
* $k_{.6} \supseteq K_{.2} \cap \{\text{x} \leq 0\}$

The *collecting semantics* is the smallest set of $K_i$'s such that the above
constrainst are satisfied. $K_i$'s belong to the range of a function $K:: Labels
\mapsto 2^{\Sigma}$, so the above constraints can be summarized in the
following: $K \supseteq F(K)$, where $F$ is a function from the current states
to the next ones. Our goal is to compute the smallest map $K$, for which this
constraint holds. We note that inclusion between two maps $K \subseteq K'$ means 
that $\forall l\ K.l \subseteq K'.l$.

A simple algorithm to compute this is the following:

~~~~~{.c}
K = \l -> {}
do {
  K_old = K;
  K = F(K_old);
} until (K == K_old)
~~~~~

What this algorithm implies is that we can define a $K_l^i$, which is the set of
states reached at a point with label $l$ after a at most $i$ execution steps. 
The set we are looking for is $K^l = \bigcup_{i\in \mathbb{N}}  K_l^i$, which 
includes all the possible steps after any number of executions.

In terms of the algorithmic procedure we describe4d above this corresponds to the 
fixed-point: $K^* = F(K^*)$. 

$K^*$ is the collecting semantics for this program.

Returning to the example above, the following table describes for every label 
$l$ and iteration step $i$, the set of values that the variables of the program 
can take.

![](lec-absint-table.svg)

So, unlike examples we have seen earlier, like *eval*, this procedure never 
converges, so it is not as useful as we would like. 


### Abstract Semantics

- Apply the algorithm on the abstract domain.

- Will have to define a $Value^{\#}$. 

- Earlier we defined an abstract domain $Int^{\#}$:\
![](figs/simple-lat.svg)

**How do we apply $Int^{\#}$ to IMP?**

- We need to encode $State$ abstractly:\
$State^{\#} : Var \mapsto Value^{\#}$

- Now we can follow the same procedure as before, but for $State^{\#}$.


**How do we transform the constraints into abstract ones?**

- The table below shows the corresponde between the main operators in the fields
of logic, set thoery and Constraint Programming:

  Logic                Sets           CPO     
---------------    ------------   --------------
$\wedge$           $\cap$         $\sqcap$          
$\vee$             $\cup$         $\sqcup$          
$\rightarrow$      $\subseteq$    $\sqsubseteq$      

- A final extension that needs to be done before expressing the constraint in
the abstract domain is defining the $\sqcup$ and $\sqcap$ for sets of abstract
values. This is done in a straight-forward manner:\
$K_1 \sqcup K_2 = \lambda l \mapsto K_1.l \sqcup K_2.l$\
$K_1 \sqcap K_2 = \lambda l \mapsto K_1.l \sqcap K_2.l$


* $K_{.0} \sqsupseteq (+, \top)$
* $k_{.1} \sqsupseteq K_{.0}[\text{y}_0/\text{y}] \sqcap (+,\top)$
* $K_{.2} \sqsupseteq K_{.1} \sqcap K_{.2} \sqsupseteq K_{.5}$
* $k_{.3} \sqsupseteq K_{.2} \sqcap (+, \top)$
* $k_{.4} \sqsupseteq K_{.3}[\text{y}_0/\text{y}] \sqcap \alpha(\text{y} = \text{y}_0 * \text{x})$
* $k_{.5} \sqsupseteq K_{.3}[\text{x}_0/\text{x}] \sqcap \alpha(\text{x} = \text{x}_0 * 1)$
* $k_{.6} \sqsupseteq K_{.2} \sqcap (\top, \top)$

We can now execute the same algorithm as above but using the abstract values.


## TODO -- abs. table

The result that we'll get will be $K^{\#} = (\top, +)$, instead of the more
precise $K^* = [(0,1),(0,1),(0,2),\dots]$. However, we sitll get a sound
solution since: $\alpha(K^*) \sqsubseteq K^{\#}$, or $K^* \subseteq
\gamma(K^{\#})$.


## Q & A

**Do we know it will terminate?**
Yes, because:
- we are moving within a finite height lattice,
- we are using monotone functions.

**Doesn't the meet operator take you lower in the lattice?**
- Yes, but the containment restriction ($\sqsupseteq), does not let us.
- The left hand side is bound to be as big as the right hand side.
