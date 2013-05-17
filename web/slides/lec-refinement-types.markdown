% Refinement Types 
% Ranjit Jhala, UC San Diego 
% May 16, 2013


Consider the following NanoJS program:

    function minIndex(a){
      requires(length(a) > 0);
      ensures(0 <= $result && $result < length(a))
      var i   = 0;
      var min = 0;
      while(i < length(a)){
        invariant(0 <= min && min < length(a));
        invariant(0 <= i);
        if (a[i] < a[min]){ 
          min = i; 
        } 
      }
      return min;
    }


How would we verify the `requires` and `ensures` clauses?

Need a loop invariant. What?

Ok.

Now, loops are for children, we can encode with recursion. 

Consider this variant:

    function minIndex(a){
      requires(length(a) > 0);
      ensures(0 <= $result && $result < (length(a)))
      function loop(min, i){
        var minNext = min;
        if (i < length(a)) {
          if (a[i] < a[min]) { minNext = i; } 
          return loop(min_new, i+1)
        }
        return min;
      }
      return loop(0, 0);
    }

Same property. How can we verify it? (Assume ESC-Nano can handle *local functions*)

Now, as we all know, its a bad idea to write *raw* recursion.

Lets factor the recursion into a higher-order loop:
    
    function forloop(lo, hi, body, acc){
      if (lo < hi) {
        var newAcc = body(lo, acc);
        return forloop(lo + 1, hi, body, newAcc);
      }
      return acc;
    }

Equipped with this loop, we can rewrite `minIndex` as:

    function minIndex(a){

      requires(length(a) > 0);
      ensures(0 <= $result && $result < (length(a)))
      
      function step(i, min){
        if (a[i] < a[min]) { return i } else { return min }
      }
      
      return forloop(0, length(a), step, 0);
    }

But now, how do we verify the property?

**Problem 1: Functions are first-class values.**

Before this, we only had to worry about `int` and `bool`
    - SMT solvers deal with those excellently.

If you felt adventurous, you might chance your luck with `array`
    - Remember `sel` and `upd` axioms for reasoning about memory

But things quickly get difficult. Consider yet another variant.

   function range(lo, hi) {
     if (lo < hi) { 
       var rest = range(lo + 1, hi); 
       return push(lo, rest); 
     }
     return nil();
   }

   function foldl(f, acc, xs){ 
     if null(xs){
       return acc;
     } else {
       var h      = head(xs);
       var accNew = f(acc, h); 
       return foldl(f, accNew, tail(xs));
     }
   }

and now, you might rewrite the humble `minIndex` as
  
    function minIndex(a){
      
      requires(length(a) > 0);
      ensures(0 <= $result && $result < (length(a)))
      
      function step(min, i){
        if (a[i] < a[min]) { return i } else { return min }
      }
      
      return foldl(step, 0, range(0, length(a)));
    }

Now in addition to worrying about the function...

**Problem 2: Containers are first-class values.**

Need to reason about contents of structures like the `list`

    - *every* element of `range(0, n)` is between `0` and `n`.

Before this, we only had to worry about `int` and `bool`
    - SMT solvers deal with those excellently.

If you felt adventurous, you might chance your luck with `array`
    - Remember `sel` and `upd` axioms for reasoning about memory

Next, we will see how to address these problems by **generalizing**
Floyd-Hoare style verification using **types**

    **Refinement Types = Types + Floyd-Hoare Logic**

Plan
----

1. First Order
    - Example: Types
    - Example: Refinements
    - Theory : Types
    - Theory : Refinements

2. Higher Order
    - Example: Types
    - Example: Refinements
    - Theory : Types
    - Theory : Refinements

3. Polymorphism
    - Example: Types
    - Example: Refinements
    - Theory : Types
    - Theory : Refinements

4. Containers
    - Example: Types
    - Example: Refinements
    - Theory : Types
    - Theory : Refinements


1A. First Order Programs: Example: Types 
----------------------------------------

Lets go back to the very beginning and revisit the programs with **types**

    function minIndex(a){
      
      function loop(min, i){
        var minNext = min;
        var n       = length(a);
        if (i < n) {
          if (get(a,i) < get(a, min)) { 
            minNext = i; 
          } 
          return loop(minNext, i+1)
        }
        return minNext;
      }
      return loop(0, 0);
    }

First, lets give the two functions types 

    /*@ minIndex :: (array int) => int */

and 

    /*@ loop :: (int, int) => int */

Lets *type-check* the code to see that these types are correct.

From `minIndex` signature we get

    a   :: array int

From `loop` signature we get

    min :: int
    i   :: int

from `minNext = min` we get

    minNext :: int

we give the builtin function

    length :: (array int) => int

and hence to typecheck the call `length(a)` we require that

    a :: array int

which it is (see above!). The output is the output type of `length` so

    n :: int

Next, the `if` should be a boolean expression, the builtin 

    (<)    :: (int, int) => bool

so the condition is actually a function call, and so

    (<) :: (int, int) => bool
    i   :: int
    n   :: bool
    ______________________________
    
    (<)(i, n) :: bool

Now, the calls to `get` also type check because

    get :: (array int, int) => int
    a   :: array int
    i   :: int
    ______________________________
    
    get(a,i) :: int

and 

    get :: (array int, int) => int
    a   :: array int
    min :: int
    ______________________________
    
    get(a,min) :: int

hence, from the above type of `(<)`

    (<)(get(a, i), get(a, min)) :: bool

Now, something interesting happens `minNext = i`.

How should we *typecheck* this?

Well, lets do the classic thing -- we **know** 

    minNext :: int

so lets check that the value being assigned to it, namely `i` is also

    i       :: int

i.e type of the **source** `i` is **compatible with** type of **target** `minNext`.

Moving on, we check that the arguments to `loop` have the right types

    loop    :: (int, int) => int 
    minNext :: int
    i+1     :: int
    ____________________________
    
    loop(minNext, i+1) :: int

Also, note that the above value is **returned**.

So must check above type is **compatible** with the **return** type of `loop`.

(Think of `return` as an **assignment** into `$result$)

Breaking out, we must check that `minNext` is also compatible. (It is.)

Finally, popping out into the call `loop(0,0)` we verify that

    loop :: (int, int) => int
    0    :: int
    0    :: int
    _________________________
    
    loop(0, 0) :: int

This expression is also **returned**.

Happily, its type **is compatible** with the output type of `minIndex`.

And we are done.

1B. First Order Programs: Example: Refinements 
----------------------------------------------

Recall our **slogan**

    **Refinement Types = Types + Floyd-Hoare Logic**

So, what **is** a refinement type? Types decorated with predicates:

    minIndex :: (a:{v:array int | 0 < (len v)}) => {v:int | 0 <= v < (len a)}

Here, read 

    {v: t | p}

as values of type `t` that **satisfy the refinement predicate* `p`

So, for example, 

    {v: int | 0 <= v < 100}

describes `int` values that are between `0` and `100` and

    {v: int | v < n}

describes `int` values that are **less than** the value of 
another program variable `n`.

    [ DIGRESSION FLOYD-HOARE-REFINEMENT-CORRESPONDENCE]

Returning to our example, we can type `loop` as:

    loop :: (min:{v:int|0 <= v < (len a)}, i:{v:int|0 <= i}) => {v:int | 0 <= v < (len a)}

Lets define a macro

    type Rng A = {v:int | 0 <= v (len A)}

and then we can shorten the above type to

    loop :: (min:(Rng a), i:{v:int|0 <= i}) => (Rng a) 

*Writing* refinement types is all well and good, but how do we *check* them?

Turns out, you can more or less mimic what the regular type checker does.

    **TODO: REDO TYPECHECKING WITH REFINEMENTS**
        
        + Gamma : environment recording what is known
        
        + Cannot prove "compatibility" at assignment
        
        + Weaken "compatibility" to "subtyping"
            
            + IF-GUARD
            + SINGLETON

        + Everything works.

Ok, before formalizing, lets look at a simpler but harder example

`abs` version 1: [SSA/Join] 

    /*@ abs :: (x:int) => {v:Int | v >= 0} */
    function abs(x){
      var res = x;
      if (x < 0) {
        res = 0 - x;
      }
      return res;
    }

`abs` version 2: [assert]

    /*@ abs :: (x:int) => {v:Int | v >= 0} */
    function abs(x){
      var res = x;
      if (x < 0) {
        res = 0 - x;
      }
      assert (res >= 0);
      return res;
    }

1C. First Order Programs: Theory 
--------------------------------


**Base Types**

    B := int 
       | bool 
       | array int 
       | list int 
       | ...

**Types**

    T := {v:B | p}                  // Base types
       | (x1:T1,...,xn:Tn) => T     // Function types



**Expressions**

    E := x                          // Variables
       | c                          // Constants 0, 1, 2 ...
       | f(e1,...,en)               // Function Call 

**Statements**

    S := skip                        
       | x = e 
       | s1; s2
       | if (e) { s1 } else { s2 }
       | return e
       | phivar x :: T              // For Phi-Vars

**Functions**
    
    F := function f(x..){s}         // Function Definition

**Programs**

    P := f1 :: T1, ... fn :: Tn     // Sequence of function definitions

**Wellformedness**

    G |- p : bool
   ________________

    G |- {v:b | p }


**Subtyping**

           [G] /\ p1 => p2
    _____________________________

    G |- {v:b | p1} <: {v:b | p2}

**Program Typing**

    G = f1 :: T1...     G |- f1 ...
    _______________________________[Program]

            0 |- f1 :: T1 ...

**Function Typing**

    G, x1:T1...,$result:T |- s  
    ___________________________[Fun]

    G |- function f(x1...){ s } 

**Expression Typing**   

    G |- e : t
    
    In environment `G` the expression `e` evaluates to a value of type `t`

    **Constants**

    ______________[E-Const]

    G |- c : ty(c) 

    ty(1) = {v:int| v = 1}
    ty(+) = (x:int, y:int) => {v:int  | v  =  x + y}
    ty(<) = (x:int, y:int) => {v:bool | v <=> x < y}

    etc.

    **Var**
    
    G(x) = {v:b | ...}
    _______________________[E-Var]

    G |- x : {v: b | v = x}


    **Calls**

    G(f) = (x1:T1...) => T     G |- e1:T1 ...
    _________________________________________[E-Call]

    G |- f(y1...) : T[y1../x1...]  


**Statement Typing**

    G |- s : G'

    G' is G extended with **new bindings** for assigments in `s`
    

    **skip**

    G |- skip : G

    **assign**

       | x = e 
    
    **sequence**

      | s1; s2
       
    **branch**

      | if (e) { s1 } else { s2 }

    **return**
       
       | return e

    **phivar**

       | phivar x :: T            


**Note** We encode unary and binary operations as function calls, e.g.

    x + y

is just

    +(x, y)

and so on...

    TODO


Floyd-Hoare / Types Correspondence
----------------------------------

Refinement Types Generalize Floyd-Hoare Logic

For an environment

    P := x1:{v:t|px1}, ...

define the formula

    [P] = px[x1/v] && ...

Now, we have the following correspondences:

1. The expression typing

    P |- e : {v:t|Q}          

corresponds to the Floyd-Hoare triple

    {[P]} z = e {Q[z/v]} 

2. The statement typing

    P |- s : P'

corresponds to the Floyd-Hoare triple

    {[P]} s {[P']}

3. The subtyping rule
 
    P |- e : t      t <: t' 
    _______________________
                
          P |- e : t'

   corresponds to the rule of consequence


    {[P]} v = e  {T}   T => T'
    __________________________

         {[P]} v = e {T'}   


4. Intuitively, base types **generalize** `assert` 

    x :: {v:int | p}

is equivalent to

    assert(p[x/v])

Similarly, function types **generalize** `requires` and `ensures`

    minIndex :: (a:{v:array int | 0 < (len v)}) => {v:int | 0 <= v < (len a)}

is equivalent to 

    requires(0 < length(a));
    
    ensures(0 <= $result < (length a));


/*@ minIndex :: (a:{v:array int | 0 < (len v)}) => {v:int | 0 <= v < (len a)} */

/*@ loop :: (min:{v:int|0 <= v < (len a)}, i:{v:int|0 <= i}) => {v:int | 0 <= v < (len a)} */

/*@ loop :: (int, int) => int */


// First order EASY
// 1. Show type checking
// *. Formalize: functions/calls/assign/if-then-else/primop
//
// 2. Show ref-type checking
// 3. Motivate need for SINGLETON [o.w. can't prove type for minIndex/abs]
// 4. Motivate need for SSA by res = x ~~~~> {z = res;  res = x;}
// *  Formalize RefTyping : functions/calls/assign/if-then-else/primop




// First order INVOLVED
// 5. Min-Index
// 6. Type-Checking
// 7. Ref-Type-Checking

// Higher-Order MONO [FUNCTION SUBTYPING]

/*@ forloop :: (int, int, (int, int) => int, int) => int */
function forloop(lo, hi, body, acc){
  if (lo < hi) {
    var newAcc = body(lo, acc);
    return forloop(lo + 1, hi, body, newAcc);
  }
  return acc;
}

/*@ define Rng A = {v:int | 0 <= v (len A)} */
/*@ minIndex :: (a:{v:array int | 0 < (len v)}) => {v:int | 0 <= v < (len a)} */
/*@ minIndex :: (a:{v:array int | 0 < (len v)}) => (Rng a) */
/*@ step :: (i:{v:int | 0 <= v < (len a)}, min:{v:int | 0 <= v < (len a)}) => {v:int | 0 <= v < (len a)} */
/*@ step :: (i:(Rng a), min:(Rng a)) => (Rng a) */

function minIndex(a){
  function step(i, min){
    var minNext = min;
    if (a[i] < a[min]){ 
      minNext = i; 
    }
    return minNext;
  }
  return forloop(0, length(a), step, 0);
}

// Higher-Order POLY [Instantiation]

/*@ forloop :: forall A. (int, int, (int, A) => A, A) => A */
function forloop(lo, hi, body, acc){
  if (lo < hi) {
    var newAcc = body(lo, acc);
    return forloop(lo + 1, hi, body, newAcc);
  }
  return acc;
}


function minIndex(a){
  function step(i, min){
    var minNext = min;
    if (a[i] < a[min]){ 
      minNext = i; 
    }
    return minNext;
  }
  return forloop/*@[(Rng a)]*/(0, length(a), step, 0);
}

// --------------------------------------------------------------------------
// Next: Collections, Poly, Fold ...

