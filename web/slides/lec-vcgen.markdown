% Floyd-Hoare Logic & Verification Conditions
% Ranjit Jhala, UC San Diego 
% April 16, 2013

## A Small Imperative Language

~~~~~{.haskell}
data Var    

data Exp   

data Pred  
~~~~~

## A Small Imperative Language

~~~~~{.haskell}
data Com = Asgn  Var Expr
         | Seq   Com Com
         | If    Exp Com Com
         | While Pred Exp Com
         | Skip
~~~~~

## Verification Condition Generation

Use the `State` monad to log individual loop invariant requirements

~~~~~{.haskell}
type VC = State [Pred]  -- validity queries for SMT solver
~~~~~

## Top Level Verification Function

The top level verifier, takes: 

- **Input**  : precondition `p`, command `c` andpostcondition `q`

- **Output** : `True` iff `{p} c {q}` is a valid Hoare-Triple

~~~~~{.haskell}
verify       :: Pred -> Com -> Pred -> Bool

verify p c q    = all smtValid queries
  where 
    (q', conds) = runState (vcgen q c) []  
    queries     = p `implies` q' : conds 
~~~~~

## Verification Condition Generator

~~~~~{.haskell}
vcgen :: Pred -> Com -> VC Pred

vcgen (Skip) q  
  = return q
vcgen (Asgn x e) q  
  = return $ q `subst` (x, e)
vcgen (Seq s1 s2) q
  = vcgen s1 =<< vcgen s2 q
vcgen (If b c1 c2) q
  = do q1    <- vcgen c1 q
       q2    <- vcgen c2 q
       return $ (b `implies` q1) `And` (Not b `implies` q2)
vcgen (While i b c) q 
  = do q'           <- vcgen c i 
       sideCondition $ (i `And` b)     `implies` q' 
       sideCondition $ (i `And` Not b) `implies` q  
       return $ i                            
~~~~~

## `vcgen` Helper Logs All Side Conditions

~~~~~{.haskell}
sideCond :: Pred -> VC ()
sideCond p = modify $ \conds -> p : conds 
~~~~~

## Next: Some Examples

Now, lets *use* the above verifier to check some programs

## Example 1

Consider the program `c` defined:

~~~~~{.javascript}
while (x > 0) {
  x = x - 1;
  y = y - 2;
}
~~~~~

Lets prove that

~~~~~{.haskell}
{x==8 && y==16} c {y == 0}
~~~~~

## Example 1

Add the pre- and post-condition with `assume` and `assert`

~~~~~{.javascript}
assume(x == 8 && y == 16);
while (x > 0) {
  x = x - 1;
  y = y - 2;
}
assert(y == 0);
~~~~~

What do we need next?

## Example 1: Adding A Loop Invariant

Lets use a *placeholder* `I` for the invariant

~~~~~{.javascript}
assume(x == 8 && y == 16);
while (x > 0) {
  invariant(I);
  x = x - 1;
  y = y - 2;
}
assert(y == 0);
~~~~~

**Question:** What should `I` be?

1. **Weak** enough to hold *initially* 
2. **Inductive** to prove *preservation*  
3. **Strong** enough to prove *goal*


## Example 1: Adding A Loop Invariant

Lets try the candidate invariant `y == 2 * x`

~~~~~{.javascript}
assume(x == 8 && y == 16);
while (x > 0) {
  invariant(y == 2 * x);
  x = x - 1;
  y = y - 2;
}
assert(y == 0);
~~~~~

1. Holds initially?  

    - SMT-Valid `(x == 8 && y == 16) => (y == 2 * x)` ?

    - **[Yes]**

## Example 1: Adding A Loop Invariant

Lets try the candidate invariant `y == 2 * x`

~~~~~{.javascript}
assume(x == 8 && y == 16);
while (x > 0) {
  invariant(y == 2 * x);
  x = x - 1;
  y = y - 2;
}
assert(y == 0);
~~~~~

2. Preserved ?  

    - SMT-Valid `(y = 2 * x && x > 0) => (y-2 == 2 * (x - 1))` ?

    - **[Yes]**

## Example 1: Adding A Loop Invariant

Lets try the candidate invariant `y == 2 * x`

~~~~~{.javascript}
assume(x == 8 && y == 16);
while (x > 0) {
  invariant(y == 2 * x);
  x = x - 1;
  y = y - 2;
}
assert(y == 0);
~~~~~

3. Strong Enough To Prove Goal?  

    - SMT-Valid `(y = 2 * x && !x > 0) => (y == 0)` ?

    - **[No]**

**Uh oh.** Close, but no cigar...

## Example 1: Adding A Loop Invariant (Take 2)

Lets try `(y == 2 * x) && (x >=0)`

~~~~~{.javascript}
assume(x == 8 && y == 16);
while (x > 0) {
  invariant(y == 2 * x && x >= 0);
  x = x - 1;
  y = y - 2;
}
assert(y == 0);
~~~~~

SMT Valid Check

1. **Initial**  `(x == 8 && y == 16) => (y == 2 * x)`
    - **Yes** 

2. **Preserve** `(y = 2 * x && x > 0) => (y-2 == 2 * (x - 1))`
    - **Yes**

3. **Goal**     `(y = 2 * x && x >=0 && !x > 0) => (y == 0)`
    - **Yes**

## Example 2 

~~~~~{.javascript}
assume(n > 0);
var k = 0;
var r = 0;
var s = 1;
while (k != n) {
  invariant(I);
  r = r + s;
  s = s + 2;
  k = k + 1;
}
assert(r == n * n);
~~~~~

**Whoa!** What's a reasonable invariant `I`?

## Example 2 

Lets try the obvious thing ... `r == k * k`

~~~~~{.javascript}
assume(n > 0);
var k = 0;
var r = 0;
var s = 1;
while (k != n) {
  invariant(r == k * k);
  r = r + s;
  s = s + 2;
  k = k + 1;
}
assert(r == n * n);
~~~~~

- **Initial**  `(k == 0 && r == 0) => (r == k * k)` **YES**
- **Goal**     `(r == k * k && k == n) => (r == n * n)` **YES**
- **Preserve** `(r== k*k && k != n) => (r + s == (k+1)*(k+1))` **NO!** 

Finding an invariant that is **preserved** can be tricky...

## Example 2 

Finding an invariant that is **preserved** can be tricky...

... typically need to **strengthen** to get preservation

... that is, to **add extra** conjuncts


## Example 2: Take 2

Strengthen `I` with facts about `s`

~~~~~{.javascript}
assume(n > 0);
var k = 0;
var r = 0;
var s = 1;
while (k != n) {
  invariant(r == k*k && s == 2*k + 1);
  r = r + s;
  s = s + 2;
  k = k + 1;
}
assert(r == n * n);
~~~~~

1. **Initial**  

- `(k == 0 && r == 0 && s==1) => (r == k*k && s == 2*k + 1)` 

- **YES**

## Example 2: Take 2

Strengthen `I` with facts about `s`

~~~~~{.javascript}
assume(n > 0);
var k = 0;
var r = 0;
var s = 1;
while (k != n) {
  invariant(r == k*k && s == 2*k + 1);
  r = r + s;
  s = s + 2;
  k = k + 1;
}
assert(r == n * n);
~~~~~

2. **Goal**

- `(r == k*k && s == 2*k + 1 && k == n) => (r == n*n)` 

- **YES**


## Example 2: Take 2

Strengthen `I` with facts about `s`

~~~~~{.javascript}
assume(n > 0);
var k = 0;
var r = 0;
var s = 1;
while (k != n) {
  invariant(r == k*k && s == 2*k + 1);
  r = r + s;
  s = s + 2;
  k = k + 1;
}
assert(r == n * n);
~~~~~

3. **Preserve** 

~~~~~{.haskell}
(r == k * k && s == 2 * k + 1 && k != n) 
  => 
(r + s == (k+1) * (k+1) && s+2 == 2 * (k+1) + 1)
~~~~~

**Yes** 


## Adding Features To IMP

- **Functions**

- Pointers

## IMP + Functions

~~~~~{.haskell}
data Fun = F String [Var] Com

data Com = ...
         | Call   Var Fun [Expr]
         | Return Expr

data Pgm = [Fun]
~~~~~

## IMP + Functions

A *function* is a big sequence of `Com` which **does not modify** formals

~~~~~{.javascript}
function f(x1,...,xn){
  requires(pre);
  ensures(post);
  body;
  return e;
}
~~~~~

### Precondition

- Predicate over the **formal** parameters `x1,...,xn`
- That records **assumption** about inputs

### Postcondition

- Predicate over the **formals** and **return value** `$result`
- That records **assertion** about outputs 

## Modular Verification With Contracts 

- Together, *pre-* and *post-* conditions called **contracts**
- We can generate VC (hence, verify) **one-function-at-a-time**
- Using just *contracts* for all called functions

### Questions

1. How to verify *each* function with *callee* contracts? 

2. How to verify `Call` commands?

## Verifying A Single Function

To verify a single function

~~~~~{.javascript}
function f(x1,...,xn){
  requires(pre);
  ensures(post);
  body;
  return e;
}
~~~~~

we need to just verify the Hoare-triple

~~~~~{.haskell}
{pre} body ; $result := r {post}
~~~~~

**Exercise** How will you handle `return` sprinkled within `body` ?

## Verifying A Single Call Command 

To establish a Hoare-triple for a single **call** command 

~~~~~{.haskell}
{P} 
   y := f(e) 
{Q}
~~~~~

1. We must **guarantee** that `pre` (of `f`) holds *before* the call
2. We can **assume** that `post (of `f`) holds *after* the call

Hence, the above triple reduces to verifying that

~~~~~{.haskell}
{P} 
   assert (pre[e1/x1,...,en/xn]) ; 
   assume (post[e1/x1,...,en/xn, y/$result];  
{Q}
~~~~~

## Caller-Callee Contract Duality

Note that at the **callsite** for a function, we

- **assert** the pre-condition
- **assume** the post-condition

while when checking the **callee** we

- **assume** the pre-condition
- **assert** the post-condition

This is key for **modular verification**

- Breaks verification up into pieces matching function abstraction 

## Example: A Locking Protocol

- Lock/Unlock
- Protocol

COPY FROM PPT

## Adding Features To IMP

- Functions

- **Pointers**

## IMP + Pointers

COPY FROM PPT

## Deductive Verifiers

We have just scratched the surface 

Many *industrial strength* verifiers for real languages

- [Why3](http://krakatoa.lri.fr/jessie.html)
- [ESC-Java](http://kindsoftware.com/products/opensource/ESCJava2/)

And these, which you can play with [online](http://rise4fun.com)

- [VCC](http://rise4fun.com/Vcc/lsearch) 
- [Spec# 1](http://rise4fun.com/SpecSharp/Add) [Spec# 2](http://rise4fun.com/SpecSharp/BinarySearch)
- [Verifast](http://rise4fun.com/VeriFast/list%20reverse)

All very impressive: Try them out and see! 

Main hassle: writing invariants, pre and post...
