Syntax
------

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

    E := x                 // Variables
       | c                 // Constants 0, 1, +, -, true...
       | f(e1,...,en)      // Function Call 

Syntax (Cont'd)
---------------


**Statements**

    S := skip                        
       | x = e 
       | s1; s2
       | if [$\phi$] (e) { s1 } else { s2 }
       | return e

**Phi-Variables**

    $\phi$ := x1:T1 ... xn:Tn

Code Transformation
-------------------

*Note*: We make the following transformations to the code
- SSA transformation
- Addition of `else` branches
- Annotate branches with $\phi$ variables

So the following code:

    /*@ abs :: (x:int) => {v:int | v>=0}*/
    function abs(x){
      r = x;
      if (x < 0){
        r = 0 - x
      };
      return r
    }

Code Transformation
-------------------

Will be transformed to:

    /*@ abs :: (x:int) => {v:int | v>=0}*/
    function abs(x){
      r0 = x0;
      if [r1:{v:int | v>=0}] 
        (x0 < 0){
        r1 = 0 - x0;
      } else {
        r1 = r0;
      };
      return r1
    }

Syntax (Cont'd)
---------------
   
**Functions**
    
    F := function f(x1...xn){s}   // Function Definition

**Programs**

    P := F1:T1, ... Fn:Tn   // List of function definitions

**Environments**

    G = x1:T1,...,xn:Tn

- A sequence of type bindings
- *Invariant*: No *duplicate* bindings
- *Invariant*: Types are *well-formed*


Wellformedness
--------------

**Wellformedness: Base**

    G, v:b |- p : bool
    ____________________[W-Base]
 
       G |- {v:b | p}

*Intuition:* `p` must be a boolean predicate in `G`

**Wellformedness: Functions**

    G, x1:T1,...,xn:Tn |- Ti  for all i in 1..n
    G, x1:T1,...,xn:Tn |- T
    ______________________________________________[W-Fun]
   
            G |- (x1:T1,...,xn:Tn) => T

    

Subtyping
---------

**Embedding Environments**

    embed                    :: G -> Predicate
    embed empty              = True                
    embed (x1:{v:B | p1}, G) = p1[x1/v] && embed G 
    embed (x1:T, G)          = embed G             

*Intuition:* Environment is like a Floyd-Hoare **Precondition**


Subtyping: Base
---------------

       (embed G) /\ p1 => p2
    _____________________________[<:-Base]

    G |- {v:b | p1} <: {v:b | p2}


*Intuition:* Subtyping is like Floyd-Hoare **Rule Of Consequence**
    
    P' => P    {P} c {Q}      Q => Q'
    _________________________________

               {P'} c {Q'}

Subtyping: Fuctions
-------------------

    
    G,yi:Ti' |- Ti' <: (Ti $\theta$)  foreach i in 1..n
    
    G,yi:Ti' |- T $\theta$ <: T'

    $\theta$ = [y1..yn/x1..xn]
    __________________________________________________[<:-Fun]

    G |- (x1:T1...xn:Tn) => T <: (y1:T1'...yn:Tn') => T'


*Intuition:* `f <: g` means that when you expected `g` you can use `f`.
- each argument of `g` should be a valid argument for `f`
- `f`'s result should be `g`'s possible result


Typing
------

**Program Typing**

    for each i in 1..n Fi = function fi(_){_} 
    
    G = f1:T1...fn:Tn

    G |- Fi:Ti for i in 1..n
    _____________________________________________[Program]

                0 |- F1:T1...Fn:Tn



**Function Typing**

    G, x1:T1...,$result:T |- s:_
    _____________________________________________________[Fun]

    G |- function f(x1:T1...xn:Tn){ s }:(x1:T1...xn:Tn)=>T 


Expression Typing
-----------------

    G |- e : t
    
In environment `G` the expression `e` evaluates to a value of type `t`

We will see this is problematic, will revisit...

Typing Constants
----------------

    ______________[E-Const]

    G |- c : ty(c) 


*Intuition:* Each constant has a *primitive* or *builtin* type

    ty(1) = {v:int| v = 1}
    
    ty(+) = (x:int, y:int) => {v:int  | v  =  x + y}
    
    ty(<) = (x:int, y:int) => {v:bool | v <=> x < y}

    etc.


Typing Variables
----------------
   
    G(x) = T 
    ___________[E-Var]

    G |- x : T 


Typing Function Calls
---------------------

    G(f) = (x1:T1...xn:Tn) => T     
    
    G |- ei:Ti'     foreach i in 1..n

    G |- Ti' <: Ti  foreach i in 1..n
    __________________________________[E-Call]

          G |- f(e1...en) : ??? 


Uh oh. What type do we give to the *output* of the call?

    + :: (x1:int, x2:int) => {v:int|v = x1 + x2}
    
    +(a,b)              : {v:int | v = a + b}
            
    +(foo(a), bar(b))   : {v:int | v = foo(a) + bar(b)}

*Problem:* In the logic we cannot reason about functions e.g., `foo` or `bar`

**Administrative Normal Form** (a.k.a. **ANF**)
-----------------------------------------------

Translate program so *every* call is of the form

    f(y1,...,yn)

That is, all arguments are **variables**

    var t1 = foo(a)
    var t2 = bar(b) 
    +(t1,t2) : {v:int | v = t1 + t2}


Typing ANF Function Calls
-------------------------

    G(f) = (x1:T1...) => T     
    
    G |- yi:Ti'         foreach i in 1..n
    
    G |- Ti' <: Ti $\theta$    foreach i in 1..n

    $\theta$ = [y1...yn/x1...xn]
    ______________________________________[E-Call]

    G |- f(y1...yn) : T $\theta$


Result type is just output type with [actuals/formals]


On the Fly ANF Conversion
-------------------------

Rejigger typing rules to perform ANF-conversion

    G |- e : G', xe

1. `G'` : the output environment with new temp binders
2. `xe` : the temp binder (in `G'`) corresponding to `e` 


**On the Fly ANF Conversion: EXAMPLE**

    G |- ((1 + 2) + 3) : G', x'
    where 
      G' = G, t0:{v = 1      }
            , t1:{v = 2      }
            , t2:{v = t1 + t2}
            , t3:{v = 3      }
            , t4:{v = t2 + t3}
      
      x' = t4


ANF-Expression Typing
---------------------

Rejigger typing rules to perform ANF-conversion

    G |- e : G', xe

1. `G'` : the output environment with new temp binders
2. `xe` : the temp binder (in `G'`) corresponding to `e` 

**Revisit Typing Rules for ANF ...**

ANF-Typing Constants
--------------------

    z is *FRESH*

    G' = G, z:ty(c)
    _________________[E-Const]

    G |- c : G', z


ANF-Typing Variables
--------------------
   

    ________________[E-Var]

     G |- x : G, x 

Yay! Easier than before ... :)


ANF Typing Function Calls
-------------------------

    G(f) = (x1:T1...) => T     
    
    G   |- e1...en : G', y1...yn

    G'  |- G'(yi) <: Ti   foreach i in 1..n

    $\theta$ = [y1...yn/x1...xn]

    G'' = G', z:T $\theta$     z is *FRESH*
    ______________________________________________[E-Call]

    G   |- f(e1...en) : G'', z  


Statement Typing
----------------

    G |- s : G'

G' is G extended with **new bindings** for assigments in `s`

**Statement Typing: skip**


    ______________[S-skip]

    G |- skip : G

Statement Typing: assign
------------------------

    G |- e : G',xe
    ________________________[S-Ass]

     G |- x = e : G',x:G'(xe)


We define `G(*)` as

    G(x) = {v:b| v = x} if x:{v:b|p} in G
           T            if x:T       in G
           

Statement Typing: sequence
--------------------------


      G  |- s1 : G1 

      G1 |- s2 : G2
      ___________________[S-Seq]

      G |- s1; s2 : G2


Statement Typing: return
------------------------

    G  |- e : G', xe
    G' |- G'(xe) <: G'($result)
    _____________________________[S-Ret]

    G  |- return e : Ø


Statement Typing: branch
------------------------

    G |- e : G', xe     
    G'(xe) = {v:boolean | ...}

    z is FRESH
    G',z:{xe}  |- s1 : G1
    G',z:{!xe} |- s2 : G2
    G1 |- G1(x) <: T    foreach x:T in $\phi$ 
    G2 |- G2(x) <: T    foreach x:T in $\phi$ 
    _______________________________________[S-If]

    G |- if [$\phi$] e { s1 } else { s2 } : G+$\phi$      

Statement Typing: branch
------------------------

*Note:* The bindings for $\phi$ variables should be checked.
The below statement should not typecheck

      if [r1:{v:int | v>=1000}] 
        (x0 < 0){
        r1 = 0 - x0;
      } else {
        r1 = r0;
      };

Examples
--------

**Example 1**

    /*@ abs :: ({x:int|true}) => {v:int|v >= 0} */ 
    function abs(x){
      var r = x;
      if (x < 0){
        r = 0 - x;
      } 
      return r;
    }
    
*Goal:* Type check the function `abs`
    
*Step 1:* Transform the program 
------------------------------
    /*@ abs :: ({x:int|true}) => {v:int|v >= 0} */ 
    function abs(x){
      /*G0*/ var r0 = x;
      if [r1:{v:int|v>=0}] (x < 0){
        /* G1  */
        r1 = 0 - x;
        /* G1' */ 
      }
      else {
        /* G2  */
        r1 = r0
        /* G2' */
      }
      /*G3*/
      return r1;
    }

*Step 2:* Compute the G environments
------------------------------------
    G0  = x:int, $return:{v:int|v>=0}
    G1  = G0, r0:{v=x},t0:{v:bool| v <=> x < 0}, t0<=>true
    G1' = G1, r1:{v=0-x}
    G2  = G0, r0:{v=x},t0:{v:bool| v <=> x < 0}, t0<=>false
    G2' = G2, r1:{v=r0}
    G3  = G0, r1:{v>=0}
    
*Step 3:* Typing of $\phi$ variables (`then` statement)
-------------------------------------- 

     (embed G1') /\ v = r1 => v>=0 
     ___________________________________
     G1' |- {v:int|v=r1} <: {v:int|v>=0}  
     ___________________________________
     G1' |- G1(r1)       <: {v>=0}      

    where 
    (embed G1') /\ v = r1 => v>=0 <=>

    r0=x  
    t0 <=> x < 0
    t0 <=>true
    r1=0-x
    v=r1
    => v>=0       OK!

*Step 3:* Typing of $\phi$ variables (`else` statement)
-------------------------------------- 

Case of `else`

     (embed G2') /\ v = r1 => v>=0 
     ___________________________________
     G2' |- {v:int|v=r1} <: {v:int|v>=0}  
     ___________________________________
     G2' |- G2'(r1)      <: {v:int|v>=0}

    where 
    (embed G2') /\ v = r1 => v>=0 <=>

    r0=x
    t0 <=> x < 0
    t0<=>false
    r1=r0
    v=r1
    => v >= 0       OK!
 
*Step 4:* Typing of `return` statement 
-------------------------------------- 
 
    r1>=0 /\ v=r1 => v>=0
    ___________________________
    (embed G3 /\ v=r1) => v>=0
    ___________________________
    G3 |- {v=r1} <: {v>=0}
    ___________________________

    G3 |- G3(r1) <: G3($result)     G3  |- r1 : G3, r1
    ___________________________________________________

    G3 |- return r1 : Ø


**Example 2**
-------------
    /*@ abs :: ((({z:int|z>=0}) => {v>=z})
                , int
               ) 
               => {v:int|v >= 0} */ 

    function abs(f, x){
      var r = x;
      if (x < 0){
        r = 0 - x;
      } 
      return f(r);
    }

**Example 2** (Cont'd)
----------------------
 
    /*@ double :: ({x:int|true}) => {v:int| v=x+x} */
    function double(x){ return x + x }

    /*@ main :: (int) => {v:int | v>=0} */
    function main(x){
      return abs(double, x);
    }

Subtyping Rule
--------------

    G,z:{v:int|v>=0} |- {z:int|z>=0}   <: {z:int|true}
               
    G,z:{v:int|v>=0} |- {v:int|v=z+z}  <: {v:int | v>=z}
    _____________________________________________________

    G |- ({x:int|true}) => {v:int| v=x+x}
         <: 
         ({z:int|z>=0}) => {v>=z}



**Example 3**
-------------
    /*@ abs :: ((({z:int|z>=0}) => {v>=z}), {x:int|true}) => {v:int|v >= 0} */ 
    function abs(f, x){
      var r = x;
      if (x < 0){
        r = 0 - x;
      } 
      return f(r);
    }

    /*@ double :: ({x:int|true}) => {v:int| v=x+x} */
    function double(x){ return x + x }

    /*@ id :: forall A. (A) => A */
    function id(x){ return x}

**Example 3** (Cont'd)
----------------------

    /*@ main :: (int) => {v:int | v>=0} */
    function main(x){
      var z = abs(double, x);
      return id(z);
    }
