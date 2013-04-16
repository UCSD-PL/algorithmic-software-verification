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
vcgen (If b c1 c2) q
  = do q1    <- vcgen q c1
       q2    <- vcgen q c2
       return $ (b `And` q1) `Or` (Not b `And` q2)
vcgen (While i b c) q 
  = do q'    <- vcgen i c
       valid  $ (i `And` Not b) `implies` q' 
       valid  $ (i `And` b)     `implies` q  
       return $ i                            
~~~~~

## `vcgen` Helper Logs All Side Conditions

~~~~~{.haskell}
valid   :: Pred -> VC ()
valid p = modifyState $ \conds -> p : conds 
~~~~~

