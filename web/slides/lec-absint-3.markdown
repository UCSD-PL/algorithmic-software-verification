% Abstract Interpretation - More Abstract Domains
% Ranjit Jhala, UC San Diego
% May 14, 2013

## Example

Recall our example from last time

~~~~~{.javascript}
   var x = nonNeg(); // assume x >= 0
2: var y = 1;
3: while(x > 0) {
     y = y * x;
     x = x - 1;
   }
~~~~~

The constraints are as follows

\begin{align*}
\top \sqcap \alpha (x > 0)                     & \sqsubseteq K_2\\
K_2[\text{y}_0/\text{y}] \sqcap \alpha (y = 1) & \sqsubseteq K_3\\
K_3[\text{y}_0/\text{y},\text{x}_0/\text{x}] \sqcap \alpha \left(
\begin{array}{l l}
      & x_0 > 0 \\
\land & y = y_0 * x_0 \\
\land & x = x_0 - 1
\end{array}
\right) & \sqsubseteq K_3
\end{align*}
## Example

We can now execute the fixpoint algorithm with the following result

|      | 1             | 2          |          3 |
|------+---------------+------------+------------|
| $K_2$ | $(\bot,\bot)$ | $(+,\top)$ |            |
| $K_3$ | $(\bot,\bot)$ | $(+,+)$    | $(\top,+)$ |

Notice that we lose all information about $x$ at the end of the loop, whereas we know from examining the code that $x$ will be 0.

## Time Complexity of Fixpoint
Let us briefly consider the time complexity of our fixpoint loop.

- For each constraint, each variable starts at $\bot$ and can only go up
  in the lattice across iterations.
- $O(|K| * |V| * H)$
    - where $V$ is the set of program variables and $H$ is the height of the lattice

## Powerset Lattice
If the domain of the original lattice is

$\Sigma^\# = \{ (-,0), (+,+), \ldots \}$

then the domain of the powerset lattice is

$2^{\Sigma^\#} = \{ \{(+,+), (-,-)\}, \{(0,+), (-,+), (0,0)\}, \ldots \}$

\vspace{1cm}

$Bot = \{\},\ Top = \Sigma^\#,\ S_1^\# \sqcup S_2^\# = S_1^\# \cup S_2^\#,\ S_1^\# \sqcap S_2^\# = S_1^\# \cap S_2^\#$

What about $\sqsubseteq$?

$S_1 \sqsubseteq S_2$

$\{a_1 \ldots a_n\} \sqsubseteq \{b_1 \ldots b_m\}$

$S_1 \subseteq S_2$ or $\forall_{1 \leq i \leq n} \exists_{1 \leq j \leq m}\ a_i \sqsubseteq b_j$

## Powerset Example
What happens when we use the powerset lattice on our example?

|      | 1      | 2              |                 3 |
|------+--------+----------------+-------------------|
| $K_2$ | $\{\}$ | $\{(+,\top)\}$ |                   |
| $K_3$ | $\{\}$ | $\{(+,+)\}$    | $\{(0,+),(+,+)\}$ |

As you can see, we have learned that at the end of the loop, $x$
cannot be negative, which is much more precise than before!

But what is the cost of using a powerset lattice? Specifically, what
is the height of our powerset lattice? Remember, the height of a
lattice is given by the shortest path from $\bot$ to $\top$.

$\{\} \sqsubseteq \{\bot\} \sqsubseteq \{\bot,0\} \sqsubseteq \{\bot,0,-\} \sqsubseteq \{\bot,0,-,+\} \sqsubseteq \{\bot,0,-,+,\top\}$

As we can see, the height of the powerset lattice is $|V| + 1$. This
works in our case, but if the base lattice is inifinitely wide, the
powerset lattice would be inifinitely tall and we could no longer
guarantee termination!

## Interval Domain
Consider the domain of integer intervals, in which we can express constraints like $x > 0$, or $3 < y \leq 7$. Since our running example only has two variables, we can conveniently depict the interval domain as a 2-dimensional graph.

\includegraphics[width=.7\linewidth]{../static/absint/intervals.pdf}

## Interval Lattice
$Bot = ([5,4],[5,4]),\ Top = ([-\infty,\infty],[-\infty,\infty])$

\vspace{1cm}

\begin{columns}
\column{.4\textwidth}
\includegraphics[width=\linewidth]{../static/absint/interval-lessthan.pdf}

\column{.6\textwidth}
\begin{align*}
   & a \sqsubseteq b\\
=\ & ([i_x,j_x],[i_y,j_y]) \sqsubseteq ([i'_x,j'_x],[i'_y,j'_y])\\
=\ & i'_x \leq i_x \land j_x \leq j'_x \land i'_y \leq i_y \land j_y \leq j'_y
\end{align*}
\end{columns}

## Interval Lattice

\begin{columns}
\column{.4\textwidth}
\includegraphics[width=\linewidth]{../static/absint/interval-join.pdf}

\column{.6\textwidth}
\begin{align*}
   & a \sqcup b\\
=\ & ([i_x,j_x],[i_y,j_y]) \sqcup ([i'_x,j'_x],[i'_y,j'_y])\\
=\ & ([min(i_x,i'_x), max(j_x,j'_x)],[min(i_y,i'_y), max(j_y,j'_y)])
\end{align*}
\end{columns}

\begin{columns}
\column{.4\textwidth}
\includegraphics[width=\linewidth]{../static/absint/interval-meet.pdf}

\column{.6\textwidth}
\begin{align*}
   & a \sqcap b\\
=\ & ([i_x,j_x],[i_y,j_y]) \sqcap ([i'_x,j'_x],[i'_y,j'_y])\\
=\ & ([max(i_x,i'_x), min(j_x,j'_x)],[max(i_y,i'_y), min(j_y,j'_y)])
\end{align*}
\end{columns}

## Interval Example

|      | 1             | 2                    |                         3 |
|------+---------------+----------------------+---------------------------|
| $K_2$ | $(\bot,\bot)$ | $([1,\infty],\top)$  |                           |
| $K_3$ | $(\bot,\bot)$ | $([1,\infty],[1,1])$ | $([0,\infty],[1,\infty])$ |

- good precision, but can't express relationships, e.g. $x = y$
- other numeric domains can express relationships
    - convex polyhedra
    - "octagons" ($\pm x \pm y \leq c$)


## Predicate Abstraction
Finally, let us consider the domain of predicates, by which we mean "anything an SMT solver can understand."

\vspace{.5cm}

$P = \{P_1, P_2, P_3, \ldots\}$

$\Sigma^\# = P \mapsto (T,F)$\ \ \ (Read: "Does it Hold?")

Alternatively, $\Sigma^\# = 2^P$

\vspace{.5cm}

Using the following definitions for $P_1 - P_3$

$P_1: x > 0,\ P_2: x = y,\ P_3: y \geq 0$

$\alpha (2,3) = \{P_1, P_3\}$

$\alpha (-7,-7) = \{P_2\}$

$\alpha (10,-10) = \{P_1\}$

## Predicate Abstraction Lattice

$Bot = P,\ Top = \{\}$

\vspace{1cm}

$\{P_1 \ldots P_n\} \sqsubseteq \{Q_1 \ldots Q_m\} = \bigwedge \{P_1 \ldots P_n\} \Rightarrow \bigwedge \{Q_1 \ldots Q_m\}$

Alternatively, $\{P_1 \ldots P_n\} \supseteq \{Q_1 \ldots Q_m\}$

\vspace{1cm}

$\{P_1 \ldots P_n\} \sqcup \{Q_1 \ldots Q_m\} = \{P_1 \ldots P_n\} \cap \{Q_1 \ldots Q_m\}$

$\{P_1 \ldots P_n\} \sqcap \{Q_1 \ldots Q_m\} = \{P_1 \ldots P_n\} \cup \{Q_1 \ldots Q_m\}$

## Predicate Abstraction Example
~~~~{.javascript}
~~~~

\begin{columns}[c]
\column{.3\textwidth}
\begin{Shaded}
\begin{Highlighting}[]
   \NormalTok{i = }\DecValTok{0}
   \NormalTok{j = n - }\DecValTok{1}
\DecValTok{1}\NormalTok{: }\KeywordTok{while} \NormalTok{(i >= }\DecValTok{0}\NormalTok{) \{}
\DecValTok{2}\NormalTok{:   assert (i < n)}
     \NormalTok{i = i + }\DecValTok{1}
     \NormalTok{j = j - }\DecValTok{1}
   \NormalTok{\}}
\end{Highlighting}
\end{Shaded}

\column{.6\textwidth}
\begin{align*}
i = 0 \land j = n - 1 & \sqsubseteq K_1\\
K_1 \land j \geq 0    & \sqsubseteq K_2\\
K_2                   & \sqsubseteq i < n\\
K_2[i_0/i,j_0/j] \sqcap
\left(
\begin{array}{l l}
      & i = i_0+1 \\
\land & j = j_0-1
\end{array}
\right) & \sqsubseteq K_1
\end{align*}
\end{columns}

\vspace{.3cm}

\begin{columns}
\column{.3\textwidth}
$P_1: i + j = n - 1$

$P_2: 0 \leq j$

\column{.6\textwidth}
\begin{longtable}[c]{llll}
\hline\noalign{\medskip}
& 1 & 2 & 3
\\\noalign{\medskip}
\hline\noalign{\medskip}
$K_1$ & $P_1P_2$ & $P_1$ & $P_1$
\\\noalign{\medskip}
$K_2$ & $P_1P_2$ & $P_1P_2$ & $P_1P_2$
\\\noalign{\medskip}
\hline
\end{longtable}
\end{columns}

