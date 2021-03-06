
module Datum.Script.Core.Eval.Value
        ( Value (..)
        , expOfValue
        , expOfPAP

        , Clo   (..)
        , PAP   (..)
        , trimValue
        , freeVarsX)
where
import Datum.Script.Core.Eval.Env
import Datum.Script.Core.Exp
import Data.Maybe
import Data.Set                         (Set)
import qualified Data.Set               as Set
import Prelude hiding (lookup)



-- | Convert a value back to an expression.
expOfValue :: Value -> Exp
expOfValue vv
 = case vv of
        -- TODO: substitute env back into exp
        -- This is used for error reporting.
        VClo (Clo xx _env) -> xx     
        VPAP pap           -> expOfPAP pap


-- | Convert a PAP back to an expression.
expOfPAP :: PAP -> Exp
expOfPAP pp
 = case pp of
        PAF f vs  -> makeXApps (XFrag f) $ map expOfValue vs
        PAP p vs  -> makeXApps (XPrim p) $ map expOfValue vs


-- | Trim the environments stored in a value to just the elements that
--   are needed by the free variables. This process fulfills the role
--   of garbage collection in the interpreter.
trimValue :: Value -> Value
trimValue vv
 = case vv of
        VClo (Clo x env)
         -> let fvs     = freeVarsX Set.empty x
                keep uu
                 = case uu of
                        UName n -> Set.member n fvs
                        _       -> True

            in  VClo (Clo x (trim keep env))

        VPAP (PAP p vs)
         ->     VPAP (PAP p (map trimValue vs))

        VPAP (PAF p vs)
         ->     VPAP (PAF p (map trimValue vs))


-- | Determine the set of unbound variables that are not
--   present in the given environment.
--
--   TODO: handle debruijn vars, or deny them in evaluator.
--
freeVarsX :: Set Name -> Exp -> Set Name
freeVarsX env xx 
 = case xx of
        XAnnot _ x      -> freeVarsX env x
        XPrim{}         -> Set.empty
        XFrag{}         -> Set.empty

        XVar (UIx _)    -> Set.empty
        XVar (UName n)
         | Set.member n env     
                        -> Set.empty
         | otherwise    -> Set.singleton n
        XVar _          -> Set.empty

        XCast _ x       -> freeVarsX env x

        XAbs (BName n) _ x      
         -> freeVarsX (Set.insert n env) x

        XAbs BAnon _ x
         -> freeVarsX env x

        XAbs _ _ x
         -> freeVarsX env x

        XApp x1 x2
         -> Set.union (freeVarsX env x1) (freeVarsX env x2)

        XRec bxs x2
         -> let (bs, xs) = unzip bxs
                ns       = mapMaybe takeNameOfBind bs
                env'     = Set.union env (Set.fromList ns) 
            in  Set.unions 
                 $ map (freeVarsX env')
                 $ x2 : xs

        XIf xScrut xThen xElse
         -> Set.unions
                [ freeVarsX env xScrut
                , freeVarsX env xThen
                , freeVarsX env xElse ]


-- | Take the name of a binder, if there is one.
takeNameOfBind :: Bind -> Maybe Name
takeNameOfBind bb
 = case bb of
        BAnon{} -> Nothing
        BName n -> Just n
        _       -> Nothing

