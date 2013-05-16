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

![](../static/absint/flow-charts.png)

**What are the semantics of a program in the form of a flow-chart?**

State of a program point is a mapping from variables to values: $\Sigma = Vars \mapsto Value$

## Concrete Semantics ("Collecting Semantics")

- Each program point has a label. 
- The set of all states that can be reached at a label is called the **collecting semantics**. 

**Definition.** $K_i$ : the set of states that are visible from label $i$.

What follow are definitions of collecting semantics for various flow chart constructs:

### For the single assignment:

![](../static/absint/assign.png)

There are two ways to express $K_j$ in terms of $K_i$:

1. $K_j = \{\sigma\left[\text{x}\mapsto\sigma\left[\text{e}\right]\right] | \sigma \in K_i\}$

2. $K_j \supseteq SP(K_i, \text{x:=e}) \implies K_j \supseteq K_i[\text{x}_0/\text{x}] \wedge \text{x} = \text{e}[\text{x}/\text{x}_0]$

### For the if branch:

![](../static/absint/if.png)


$K_l \supseteq K_i \cap \{\rho\} \qquad\qquad\qquad\qquad K_m\supseteq K_i \cap \{\neg\rho\}$ 


### For the join statement:

![](../static/absint/join.png)

$K_l \supseteq K_i \wedge K_l\supseteq K_j$ 




## Example:

~~~~~{.javascript}
var x = nonNeg(); // assume x >= 0
var y = 1;
while(x > 0) {
  y = y * x;
  x = x - 1;
}
~~~~~

![](../static/absint/example.png)


### Concrete Semantics

The states at every point in the flow chart above satisfy the following constraints:

* $K_{.0} \supseteq \{\text{x} > 0\}$
* $k_{.1} \supseteq K_{.0}[\text{y}_0/\text{y}] \wedge \text{y} = 1$
* $K_{.2} \supseteq K_{.1} \wedge K_{.2} \supseteq K_{.5}$
* $K_{.3} \supseteq K_{.2} \cap \{\text{x} > 0\}$
* $K_{.4} \supseteq K_{.3}[\text{y}_0/\text{y}] \wedge \text{y} = \text{y}_0 * \text{x}$
* $K_{.5} \supseteq K_{.3}[\text{x}_0/\text{x}] \wedge \text{x} = \text{x}_0 - 1$
* $K_{.6} \supseteq K_{.2} \cap \{\text{x} \leq 0\}$

### Collecting semantics
- The smallest set of $K_i$'s such that the above constraints are satisfied. 

- $K_i$'s belong to the range of the function $K:: Labels \mapsto 2^{\Sigma}$

- So the above constraints can be summarized as: $K \supseteq F(K)$, 
  where $F$ is a function from the current states to the next ones. 
  
- Our goal is to compute the smallest map $K$ for which this constraint holds. 

- Note that inclusion between two maps $K \subseteq K'$ means that 
  $\forall l\ K.l \subseteq K'.l$.

### Simple fixpoint algorithm

~~~~~
K = \l -> {}
repeat
  K_old = K
  K = F(K_old)
until (K == K_old)
~~~~~

- We can define $K_l^i$: set of states reached at a point with label $l$
  after a at most $i$ execution steps.
  
- $K^l = \bigcup_{i\in \mathbb{N}}  K_l^i$ includes all the possible steps 
  after any number of executions.

- In terms of our algorithm this corresponds to the fixed-point: $K^* = F(K^*)$. 

- $K^*$ is the collecting semantics for this program.

Returning to the example above, the following table describes for every label 
$l$ and loop iteration $i$, the set of values that the variables of the program 
can take.

![](../static/absint/lec-absint-table-conc.png)

In the above table:

- The vertical axis refers to the labels present in the program.
- The horizontal axis refers to loop iterations.
- Results for every label are squashed into the same iteration cycle.

As far as termination is concerned:

- Examples we have seen earlier, like *eval*, always terminated.

- This procedure, however, never converges, so it is not as useful as we would like. 


### Abstract Semantics

- Apply the algorithm on the abstract domain.

- Will have to define a $Value^{\#}$. 

- Earlier we defined an abstract domain $Int^{\#}$:\
![](../static/absint/simple-lat.png)

**How do we apply $Int^{\#}$ to IMP?**

- We need to encode $State$ abstractly:\
$State^{\#} : Var \mapsto Value^{\#}$

- Now we can follow the same procedure as before, but for $State^{\#}$.


**How do we transform the constraints into abstract ones?**

- Below lies the correspondence between the main operators in the 
fields of logic, set theory and constraint programming (CPO):

  Logic                Sets           CPO
---------------    ------------   --------------
$\wedge$           $\cap$         $\sqcap$          
$\vee$             $\cup$         $\sqcup$          
$\rightarrow$      $\subseteq$    $\sqsubseteq$      

- Also, need to define $\sqcup$ and $\sqcap$ for sets of abstract values. 

- This is done in a straight-forward manner:

$K_1 \sqcup K_2 = \lambda l \mapsto K_1.l \sqcup K_2.l$\
$K_1 \sqcap K_2 = \lambda l \mapsto K_1.l \sqcap K_2.l$

### Abstract constraints for the above example:

* $K_{.0} \sqsupseteq (\top, \top)$
* $K_{.1} \sqsupseteq K_{.0}[\text{y}_0/\text{y}] \sqcap (\top,+)$
* $K_{.2} \sqsupseteq K_{.1} \sqcap K_{.2} \sqsupseteq K_{.5}$
* $K_{.3} \sqsupseteq K_{.2} \sqcap (+, \top)$
* $K_{.4} \sqsupseteq K_{.3}[\text{y}_0/\text{y}] \sqcap \alpha(\text{y} = \text{y}_0 * \text{x})$
* $K_{.5} \sqsupseteq K_{.3}[\text{x}_0/\text{x}] \sqcap \alpha(\text{x} = \text{x}_0 * 1)$
* $K_{.6} \sqsupseteq K_{.2} \sqcap (\top, \top)$

We can now execute the same algorithm as above but using the abstract values.


![](../static/absint/lec-absint-table-abs.png)

- As result we get $K^{\#} = (\top, +)$.

- Instead of the more precise $K^* = [(0,1),(0,1),(0,2),\dots]$. 

- However, we still get a sound solution since: 
  $\alpha(K^*) \sqsubseteq K^{\#}$, or $K^* \subseteq \gamma(K^{\#})$.


## Q & A

**Do we know it will terminate?**

Yes, because:

- we are moving within a finite height lattice,
- we are using monotone functions.

**Doesn't the meet operator take you lower in the lattice?**

- Yes, but the containment restriction ($\sqsupseteq$), does not let us move lower.
- The left hand side is bound to be as big as the right hand side.
