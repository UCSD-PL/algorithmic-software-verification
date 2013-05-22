
First Order Programs
--------------------

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












**Statements**

    S := skip                        
       | x = e 
       | s1; s2
       | if [φ] (e) { s1 } else { s2 }
       | return e

**Phi-Variables**

    φ := x1:T1 ... xn:Tn

    // OLD

    /*@ abs :: (x:int) => {v:int | v>=0}
    function abs(x){
      r = x;
      if (x < 0){
        r = 0 - x
      }
      return r
    }



    // SSA Transformed
    r0 = x0;
    if [r1:{v:int | v >= 1000 }] 
      (x0 < 0){
      r1 = 0 - x0;
    } else {
      r1 = r0
    }
    return r1 // v>= 1000










**Functions**
    
    F := function f(x1...xn){s}   // Function Definition



**Programs**

    P := f1:T1, ... fn:Tn   // Sequence of function definitions














**Environments**

    G = x1:T1,...,xn:Tn


    - A sequence of type bindings
    - No *duplicate* bindings








**Wellformedness**

    G |- p : bool
   ________________

    G |- {v:b | p}

    
    *Intuition* `p` must be a boolean predicate in `G`









**Embedding Environments**

    embed                    :: G -> Predicate
    embed empty              = True                -- Empty Environment
    embed (x1:{v:B | p1}, G) = p1[x1/v] && embed G -- Base     Binding
    embed (x1:T, G)          = embed G             -- Non-Base Binding

    Intuition: Environment is like a Floyd-Hoare **Precondition**

    




**Subtyping**

       (embed G) /\ p1 => p2
    _____________________________

    G |- {v:b | p1} <: {v:b | p2}





    
    G,yi:Ti' |- Ti' <: (Ti θ)  foreach i in 1..n
    
    G,yi:Ti' |- T θ <: T'

    θ = [y1..yn/x1..xn]
    ______________________________________________________

    G |- (x1:T1...xn:Tn) => T <: (y1:T1'...yn:Tn') => T'














    Intuition: Subtyping is like Floyd-Hoare **Rule Of Consequence**
    
    P' => P    {P} c {Q}      Q => Q'
    _________________________________

               {P'} c {Q'}







**Program Typing**

    G = f1:T1...fn:Tn

    G |- fi:Ti for i in 1..n
    ___________________________[Program]

      0 |- f1:T1...fn:Tn





**Function Typing**

    G, x1:T1...,$result:T |- s  
    ___________________________[Fun]

    G |- function f(x1...){ s } 









**Expression Typing**   

    G |- e : t
    
    In environment `G` the expression `e` evaluates to a value of type `t`

    We will see this is problematic, will revisit...







**Typing Constants**

    ______________[E-Const]

    G |- c : ty(c) 



    Intuition: Each constant has a *primitive* or *builtin* type

    ty(1) = {v:int| v = 1}
    
    ty(+) = (x:int, y:int) => {v:int  | v  =  x + y}
    
    ty(<) = (x:int, y:int) => {v:bool | v <=> x < y}

    etc.











**Typing Variables**
   
      G(x) = T 
    _____________[E-Var]

     G |- x : T 







**Typing Function Calls**

    G(f) = (x1:T1...xn:Tn) => T     
    
    G |- ei:Ti'     foreach i in 1..n

    G |- Ti' <: Ti  foreach i in 1..n
    ____________________________________[E-Call]

    G |- f(e1...en) : ??? 

    Uh oh. What type do we give to the *output* of the call?

    + :: (x1:int, x2:int) => {v:int|v = x1 + x2}
    
    +(a,b)              : {v:int | v = a + b}
            
    +(foo(a), bar(b))   : {v:int | v = foo(a) + bar(b)}

    var t1 = foo(a)
    var t2 = bar(b) 
    +(t1,t2)



        



**Administrative Normal Form**

a.k.a. **ANF**

Translate program so *every* call is of the form

    f(y1,...,yn)

That is, all arguments are **variables**





**Typing ANF Function Calls**

    G(f) = (x1:T1...) => T     
    
    G |- yi:Ti'         foreach i in 1..n
    
    G |- Ti' <: Ti θ    foreach i in 1..n

    Θ = [y1...yn/x1...xn]
    ______________________________________[E-Call]

    G |- f(y1...yn) : T θ 

    Result type is just output type with [actuals/formals]














**On the Fly ANF Conversion**

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








**Revisit Typing Rules for ANF ...**









**ANF-Expression Typing**   

Rejigger typing rules to perform ANF-conversion

    G |- e : G', xe

    1. `G'` : the output environment with new temp binders
    2. `xe` : the temp binder (in `G'`) corresponding to `e` 







**ANF-Typing Constants**

    z is *FRESH*

    G' = G, z:ty(c)
    _________________[E-Const]

    G |- c : G', z














**ANF-Typing Variables**
   

    ________________[E-Var]

     G |- x : G, x 



    Yay! Easier than before ... :)





**ANF Typing Function Calls**

    G(f) = (x1:T1...) => T     
    
    G   |- e1...en : G', y1...yn

    G'  |- G'(yi) <: Ti   foreach i in 1..n

    θ   = [y1...yn/x1...xn]

    G'' = G', z:T θ     z is *FRESH*
    ______________________________________________[E-Call]

    G   |- f(e1...en) : G'', z  




















**Statement Typing**

    G |- s : G'

    G' is G extended with **new bindings** for assigments in `s`








**Statement Typing: skip**

    G |- skip : G












**Statement Typing: assign**


         G |- e : G',xe
    ________________________

     G |- x = e : G',x:G(xe)


    G(x) = {v:b| v = x} if T == {v:b|p}
           T               otherwise
           











**Statement Typing: sequence**


       G  |- s1 : G1 

       G1 |- s2 : G2
      ___________________[Seq]

      G |- s1; s2 : G2









**Statement Typing: return**


    G  |- e : G', xe
    G' |- G'(xe) <: G'($result)
    _____________________________[Ret]

    G  |- return e : Ø















**Statement Typing: branch**


    G |- e : G', xe     
    G'(xe) = {v:boolean | ...}

    z is FRESH
    G',z:{xe}  |- s1 : G1
    G',z:{!xe} |- s2 : G2
    G1 |- G1(x) <: T    foreach x:T in φ 
    G2 |- G2(x) <: T    foreach x:T in φ 
    ___________________________________

    G |- if [φ] e { s1 } else { s2 } : G+φ      
















**Example 1**

    /*@ abs :: ({x:int|true}) => {v:int|v >= 0} */ 
    function abs(x){
      var r = x;
      if (x < 0){
        r = 0 - x;
      } 
      return r;
    }

    /*@ abs :: ({x:int|true}) => {v:int|v >= 0} */ 
    function abs(x){
      /*G0*/ var r0 = x;
      if [r1:{v:int|v>=0}] (x < 0){
        /* G1  */
        r1 = 0 - x;
      } /* G1' */ 
      else {
        /* G2 */
        r1 = r0
      } /* G2' */
      return r1;
    }

    G0  = x:int
    G1  = G0, r0:{v=x},t0:{v:bool| v <=> x < 0}, t0<=>true
    G1' = G1, r1:{v=0-x}
    
    G1' |- G1'(r1) <: {v:int|v >=0}      
    
    G1' |- {v=r1} <: {v >=0}      

r0=x
t0 <=> x < 0
t0<=>true
r1=0-x
v=r1
=> v >= 0       OK!

r0=x
t0 <=> x < 0
t0<=>false
r1=r0
v=r1
=> v >= 0       OK!
 
G0,r1:{v>=0} |- {v=r1} <: {v>=0}



    G2  = G0, r0:{v=x},t0:{v:bool| v <=> x < 0}, t0<=>false
    G2' = G2, r1:{v=r0}
    
    G2' |- G2'(r1) <: {v:int|v>=0}




















    /*@ abs :: ({x:int|true}) => {v:int|v >= 0} */ 
    function abs(x){
      var r = x;
      if (x < 0){
        r = 0 - x;
      } 
      return r;
    }









**Example 2**

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




    /*@ double :: ({x:int|true}) => {v:int| v=x+x} */
    function double(x){ return x + x }

    /*@ main :: (int) => {v:int | v>=0} */
    function main(x){
      return abs(double, x);
    }

    G |- {x:int|x>=0}    <: {x:int|true}
               
    G,x:{v:int|v>=0} |- {v:int| v=x+x}  <: {v:int | v>=x}
    _____________________________________________

    G |- ({x:int|true}) => {v:int| v=x+x}
         <: 
         (({z:int|z>=0}) => {v>=z})








**Example 3**

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

    /*@ main :: (int) => {v:int | v>=0} */
    function main(x){
      var z = abs(double, x);
      return id(z);
    }
