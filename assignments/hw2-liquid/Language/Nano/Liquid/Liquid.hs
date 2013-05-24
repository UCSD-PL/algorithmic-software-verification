{-# LANGUAGE OverlappingInstances #-}

-- | Top Level for Refinement Type checker

module Language.Nano.Liquid.Liquid (verifyFile) where

-- import           Text.Printf                        (printf)
import           Text.PrettyPrint.HughesPJ          (Doc, text, render, ($+$), (<+>))
import           Control.Monad
import           Control.Applicative                ((<$>))
import           Data.Maybe                         (fromJust) -- fromMaybe, isJust)

import           Language.ECMAScript3.Syntax
import           Language.ECMAScript3.PrettyPrint
import qualified Language.Fixpoint.Types as F
import           Language.Fixpoint.Misc
import           Language.Fixpoint.PrettyPrint
import           Language.Fixpoint.Interface        (solve)
import           Language.Nano.Errors
import           Language.Nano.Types
import           Language.Nano.Typecheck.Types
import           Language.Nano.Typecheck.Parse
import           Language.Nano.Typecheck.Typecheck  (typeCheck) 
import           Language.Nano.SSA.SSA

-- import qualified Language.Nano.Env as E 
import           Language.Nano.Liquid.Types
import           Language.Nano.Liquid.CGMonad

--------------------------------------------------------------------------------
verifyFile     :: FilePath -> IO (F.FixResult SourcePos)
--------------------------------------------------------------------------------
verifyFile f   = reftypeCheck f . typeCheck . ssaTransform =<< parseNanoFromFile f

-- DEBUG VERSION 
ssaTransform' x = tracePP "SSATX" $ ssaTransform x 

reftypeCheck   :: FilePath -> Nano AnnType RefType -> IO (F.FixResult SourcePos)
reftypeCheck f = solveConstraints f . generateConstraints  

--------------------------------------------------------------------------------
solveConstraints :: FilePath -> F.FInfo Cinfo -> IO (F.FixResult SourcePos) 
--------------------------------------------------------------------------------
solveConstraints f ci 
  = do (r, sol) <- solve f [] ci
       let r'    = fmap (srcPos . F.sinfo) r
       renderAnnotations sol
       donePhase (F.colorResult r) (F.showFix r) 
       return r'

renderAnnotations   :: a -> IO ()
renderAnnotations _ 
  = donePhase Loud "Ask Santa to: render inferred types (pull request forthcoming)"


--------------------------------------------------------------------------------
generateConstraints     :: NanoRefType -> F.FInfo Cinfo 
--------------------------------------------------------------------------------
generateConstraints pgm = getFInfo pgm $ consNano pgm

--------------------------------------------------------------------------------
consNano     :: NanoRefType -> CGM ()
--------------------------------------------------------------------------------
consNano pgm@(Nano {code = Src fs}) 
  = error "TO BE DONE" 

initCGEnv pgm = CGE (specs pgm) F.emptyIBindEnv []

--------------------------------------------------------------------------------
consFun :: CGEnv -> FunctionStatement AnnType -> CGM CGEnv  
--------------------------------------------------------------------------------
-- | see "ANF Typing Function Calls": from lecture notes
-- `ft` is THE TYPE of the function. That is, it is the 
--  explicit refinement type if one was provided, and 
--  otherwise it is a "fresh template" with unknown 
--  refinements K. Use @envAddFun@ to add the bindings 
--  for the function into the environment before checking
--  the function body.

consFun g (FunctionStmt l f xs body) 
  = do ft <- freshTyFun g l =<< getDefType f
       error "TO BE DONE"

-----------------------------------------------------------------------------------
envAddFun :: AnnType -> CGEnv -> Id AnnType -> [Id AnnType] -> RefType -> CGM CGEnv
-----------------------------------------------------------------------------------
-- | This function adds the relevant bindings; tyVars, arguments 
--   after renaming the names in the types to the function's formals.

envAddFun l g f xs ft = envAdds tyBinds =<< envAdds (varBinds xs ts') =<< (return $ envAddReturn f t' g) 
  where  
    (αs, yts, t)      = fromJust $ bkFun ft
    tyBinds           = [(Loc (srcPos l) α, tVar α) | α <- αs]
    varBinds          = safeZip "envAddFun"
    (su, ts')         = renameBinds yts xs 
    t'                = F.subst su t

-----------------------------------------------------------------------------------
renameBinds          :: [Bind F.Reft] -> [Id AnnType] -> (F.Subst, [RefType]) 
-----------------------------------------------------------------------------------
renameBinds yts xs   = (su, [F.subst su ty | B _ ty <- yts])
  where 
    su               = F.mkSubst $ safeZipWith "renameArgs" fSub yts xs 
    fSub yt x        = (b_sym yt, F.eVar x)

--------------------------------------------------------------------------------
consStmts :: CGEnv -> [Statement AnnType]  -> CGM (Maybe CGEnv) 
--------------------------------------------------------------------------------
consStmts = consSeq consStmt

--------------------------------------------------------------------------------
consStmt :: CGEnv -> Statement AnnType -> CGM (Maybe CGEnv) 
--------------------------------------------------------------------------------

-- | @consStmt g s@ returns the environment extended with binders that are
-- due to the execution of statement s. @Nothing@ is returned if the
-- statement has (definitely) hit a `return` along the way.

-- skip
consStmt g (EmptyStmt _) 
  = return $ Just g

-- x = e
consStmt g (ExprStmt _ (AssignExpr _ OpAssign (LVar lx x) e))   
  = consAsgn g (Id lx x) e

-- e
consStmt g (ExprStmt _ e)   
  = error "TO BE DONE" 

-- s1;s2;...;sn
consStmt g (BlockStmt _ stmts) 
  = error "TO BE DONE"

-- if b { s1 }
consStmt g (IfSingleStmt l b s)
  = consStmt g (IfStmt l b s (EmptyStmt l))

-- HINT: 
-- 0. See "Statement Typing: branch" in lecture notes
--    https://github.com/UCSD-PL/algorithmic-software-verification/blob/master/web/slides/lec-refinement-types-3.markdown
-- 1. Use @envAddGuard True@ and @envAddGuard False@ to add the binder 
--    from the condition expression @e@ into @g@ to obtain the @CGEnv@ 
--    for the "then" and "else" statements @s1@ and @s2 respectively. 
-- 2. Recursively constrain @s1@ and @s2@ under the respective environments.
-- 3. Combine the resulting environments with @envJoin@ 

-- if e { s1 } else { s2 }
consStmt g (IfStmt l e s1 s2)
  = error "TO BE DONE"
   
-- var x1 [ = e1 ]; ... ; var xn [= en];
consStmt g (VarDeclStmt _ ds)
  = error "TO BE DONE"

-- return e 
consStmt g (ReturnStmt l (Just e))
  = error "TO BE DONE"

-- return
consStmt _ (ReturnStmt _ Nothing)
  = return Nothing 

-- function f(x1...xn){ s }
consStmt g s@(FunctionStmt _ _ _ _)
  = Just <$> consFun g s

-- OTHER (Not handled)
consStmt _ s 
  = errorstar $ "consStmt: not handled " ++ ppshow s

----------------------------------------------------------------------------------
envJoin :: AnnType -> CGEnv -> Maybe CGEnv -> Maybe CGEnv -> CGM (Maybe CGEnv)
----------------------------------------------------------------------------------
envJoin _ _ Nothing x           = return x
envJoin _ _ x Nothing           = return x
envJoin l g (Just g1) (Just g2) = Just <$> envJoin' l g g1 g2 

----------------------------------------------------------------------------------
envJoin' :: AnnType -> CGEnv -> CGEnv -> CGEnv -> CGM CGEnv
----------------------------------------------------------------------------------

-- HINT: (see Statement Typing: branch from lecture notes)
-- 1. use @envFindTy@ to get types for each phi-var x in xs in the respective 
--    environments g1 AND g2
-- 2. use @freshTyPhis@ to generate fresh types (and an extended environment with 
--    the fresh-type bindings) for all the phi-vars using the unrefined types 
--    from step 1.
-- 3. generate subtyping constraints between the types from step 1 and the fresh types
-- 4. return the extended environment.

envJoin' l g g1 g2
  = do let xs   = [x | PhiVar x <- ann_fact l] 
       error "TO BE DONE"

----------------------------------------------------------------------------------
consVarDecl :: CGEnv -> VarDecl AnnType -> CGM (Maybe CGEnv) 
----------------------------------------------------------------------------------

consVarDecl g (VarDecl _ x (Just e)) 
  = consAsgn g x e  

consVarDecl g (VarDecl _ _ Nothing)  
  = return $ Just g

----------------------------------------------------------------------------------
consAsgn :: CGEnv -> Id AnnType -> Expression AnnType -> CGM (Maybe CGEnv) 
----------------------------------------------------------------------------------
consAsgn g x e 
  = error "TO BE DONE"

------------------------------------------------------------------------------------
consExpr :: CGEnv -> Expression AnnType -> CGM (Id AnnType, CGEnv) 
------------------------------------------------------------------------------------

-- | @consExpr g e@ returns a pair (g', x') where
--   x' is a fresh, temporary (A-Normalized) holding the value of `e`,
--   g' is g extended with a binding for x' (and other temps required for `e`)

-- n
consExpr g (IntLit l i)               
  = envAddFresh l (eSingleton tInt i) g

-- b
consExpr g (BoolLit l b)
  = envAddFresh l (pSingleton tBool b) g 

-- x
consExpr g (VarRef _ x)
  = error "TO BE DONE"

-- op e
consExpr g (PrefixExpr l o e)
  = do (x', g') <- consCall g l o [e] (prefixOpTy o $ renv g)
       return (x', g')

-- e1 op e2
consExpr g (InfixExpr l o e1 e2)        
  = do (x', g') <- consCall g l o [e1, e2] (infixOpTy o $ renv g)
       return (x', g')

-- e(e1,...,en)
consExpr g (CallExpr l e es)
  = error "TO BE DONE"

consExpr _ e 
  = errorstar "consExpr: not handled" (pp e)


---------------------------------------------------------------------------------------------
consCall :: (PP a) 
         => CGEnv -> AnnType -> a -> [Expression AnnType] -> RefType -> CGM (Id AnnType, CGEnv)
---------------------------------------------------------------------------------------------

-- HINT: This code is almost isomorphic to the version in 
--   @Liquid.Nano.Typecheck.Typecheck@ except we use subtyping
--   instead of unification.
--   
--   0. See the rule "Typing ANF + Polymorphic Function Calls" in lecture notes
--   1. Fill in @instantiate@ to get a monomorphic instance of @ft@ 
--      i.e. the callee's RefType, at this call-site (You may want to use @freshTyInst@)
--   2. Use @consExpr@, perhaps with @consScan@, to determine types 
--      for arguments @es@
--   3. Use @renameBinds@ to get the variable substitution θ (from lecture rule) 
--      and also the substituted input types.
--   3. Use @subTypes@ to add constraints between the types from (step 2) 
--      and (step 1)
--   4. Use the θ returned in step 3 to substitute formals with actuals 
--      in output type...

consCall g l _ es ft 
  = do (_,its,ot)   <- fromJust . bkFun <$> instantiate l g ft
       error "TO BE DONE"

instantiate :: AnnType -> CGEnv -> RefType -> CGM RefType
instantiate l g t = error "TO BE DONE"
  where 
    (αs, tbody)   = bkAll t
    τs            = getTypArgs l αs 

getTypArgs :: AnnType -> [TVar] -> [Type] 
getTypArgs l αs
  = case [i | TypInst i <- ann_fact l] of 
      [i] | length i == length αs -> i 
      _                           -> errorstar $ bugMissingTypeArgs $ srcPos l

---------------------------------------------------------------------------------
consScan :: (CGEnv -> a -> CGM (b, CGEnv)) -> CGEnv -> [a] -> CGM ([b], CGEnv)
---------------------------------------------------------------------------------
consScan step g xs  = go g [] xs 
  where 
    go g acc []     = return (reverse acc, g)
    go g acc (x:xs) = do (y, g') <- step g x
                         go g' (y:acc) xs

---------------------------------------------------------------------------------
consSeq  :: (CGEnv -> a -> CGM (Maybe CGEnv)) -> CGEnv -> [a] -> CGM (Maybe CGEnv) 
---------------------------------------------------------------------------------
consSeq f           = foldM step . Just 
  where 
    step Nothing _  = return Nothing
    step (Just g) x = f g x

