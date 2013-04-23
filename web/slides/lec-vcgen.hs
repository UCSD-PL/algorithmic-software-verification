module VCGen where

data Var 
data Exp 
data Com = Asgn  Var Expr
         | Seq   Com Com
         | If    Exp Com Com
         | While Pred Exp Com
         | Skip

----------------------------------------------------------------------------
-- | We will use the State monad to log all the individual queries that
--   arise due to checking of loop invariants.
----------------------------------------------------------------------------

type VC = State [Pred]

-----------------------------------------------------------------------------
verify       :: Pred -> Com -> Pred -> Bool
-----------------------------------------------------------------------------

-- | The top level verifier, takes: 
--   input  : precondition `p`, command `c` andpostcondition `q`
--   output : TRUE iff {p} c {q} is a valid Hoare-Triple

verify          :: Pred -> Com -> Pred -> Bool

verify p c q    = all smtValid queries
  where 
    (q', conds) = runState (vcgen q c) []  
    queries     = p `implies` q' : conds 

-----------------------------------------------------------------------------
vcgen                 :: Pred -> Com -> VC Pred
-----------------------------------------------------------------------------

vcgen (Skip)       q  = return q

vcgen (Asgn x e)   q  = return $ q `subst` (x, e)

vcgen (If b c1 c2) q  = do q1    <- vcgen q c1
                           q2    <- vcgen q c2
                           return $ (b `And` q1) `Or` (Not b `And` q2)

vcgen (While i b c) q = do q'    <- vcgen i c
                           valid  $ (i `And` Not b) `implies` q' -- require i is inductive 
                           valid  $ (i `And` b)     `implies` q  -- require q holds at exit 
                           return $ i                            -- require i holds on entry

----------------------------------------------------------------------------
valid :: Pred -> VC ()
----------------------------------------------------------------------------

-- | `valid p` adds `p` to the list of side-conditions that must be checked.

valid p = modifyState (p :) 


