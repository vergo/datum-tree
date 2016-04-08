{-# OPTIONS_HADDOCK hide #-}
module Datum.Data.Tree.SExp.Pretty where
import Datum.Data.Tree.Exp
import Text.PrettyPrint.Leijen
import Prelude                  hiding ((<$>))


ssym n          = parens $ text n
sexp n d        = parens $ text n <+> d


-- Trees ----------------------------------------------------------------------
-- | Pretty print a a checked tree using S-expression syntax.
-- 
--   * To display an unchecked tree, split it into the branch and branch type,
--     then print those separately.
--
ppTree :: Tree 'O -> Doc
ppTree (Tree b bt)
        =   sexp "tree"
        $   line
        <>  ppBranchType bt
        <$> ppBranch b


-- | Pretty print a checked forest using S-expression syntax.
--
--   * To dispaly an unchecked tree, split it into the branch and branch type,
--     then print those seprately.
--
ppForest :: Forest 'O -> Doc
ppForest (Forest g bt)
        =   sexp "forest"
        $   line
        <>  ppBranchType bt
        <$> ppGroup g


-- BranchType -----------------------------------------------------------------
-- | Pretty print a `BranchType` using S-expression syntax.
ppBranchType :: BranchType -> Doc
ppBranchType (BT name tt [])
        =   parens
        $   text "tbranch"
        <+> text (show name)
        <>  (nest 8 $ line
                <>  ppTupleType tt)


ppBranchType (BT name tt bts)
        =   parens
        $   text "tbranch"
        <+> text (show name)
        <>  (nest 8 $ line 
                <>  ppTupleType tt
                <$> vsep (map ppBranchType bts))


-- Branch ---------------------------------------------------------------------
-- | Pretty print a `Branch` using S-expression syntax.
ppBranch :: Branch -> Doc

ppBranch (B t [])
        = ppTuple t

ppBranch (B t subs)
        =   sexp "branch"  
        $   ppTuple t 
        <>  (nest 8 $ line <> vsep (map ppGroup subs))


-- Group ----------------------------------------------------------------------
-- | Pretty print a `Group` using S-expression syntax.
ppGroup :: Group -> Doc

ppGroup (G Nothing [])
        = ssym "group"

ppGroup (G Nothing [b])
        = ppBranch b

ppGroup (G Nothing bs)
        = sexp "group" $ vsep (map ppBranch bs)

ppGroup (G (Just n) [])
        = sexp "group" $ text (show n)

ppGroup (G (Just n) bs)
        = sexp "group" $ text (show n) <$> vsep (map ppBranch bs)


-- Keys -----------------------------------------------------------------------
-- | Pretty print a `Key` using S-expression syntax.
ppKey :: Key 'O -> Doc
ppKey (Key t tt)
        = sexp "key" $ ppTuple t <+> ppTupleType tt

ppKeyList :: [Key 'O] -> Doc
ppKeyList ks
        = vsep $ map ppKey ks


ppKeyNamed :: Key 'O -> Doc
ppKeyNamed (Key (T as) (TT nts))
 = parens $ hcat (punctuate (text ", ") (zipWith ppAT as nts))
 where  
        ppAT atom (name, _)
         =   text name 
         <+> text "=" <+> ppAtom     atom


-- Tuples ---------------------------------------------------------------------
-- | Pretty print a `TupleType` using S-expression syntax.
ppTupleType :: TupleType -> Doc
ppTupleType (TT nts)
        = sexp "ttype " 
        $ nest 8 
        $ vsep (map ppElementType nts)


ppElementType :: (Name, AtomType) -> Doc
ppElementType (n, t)
        = sexp "telement" $ text (show n) <+> ppAtomType t

-- | Pretty print a `Tuple` using S-expression syntax.
ppTuple :: Tuple -> Doc
ppTuple (T [])
        = ssym "tuple"

ppTuple (T as)
        = sexp "tuple" $ (hsep $ map ppAtom as)


-- Atoms ----------------------------------------------------------------------
-- | Pretty print an `AtomType` using S-expression syntax.
ppAtomType :: AtomType -> Doc
ppAtomType at
 = case at of
        ATUnit          -> text "tunit"
        ATBool          -> text "tbool"
        ATInt           -> text "tint"
        ATFloat         -> text "tfloat"
        ATNat           -> text "tnat"
        ATDecimal       -> text "tdecimal"
        ATText          -> text "ttext"
        ATTime          -> text "ttime"


-- | Pretty print an `Atom` using S-expression syntax.
ppAtom :: Atom -> Doc
ppAtom aa
 = case aa of
        AUnit           
         -> ssym "unit"

        ABool b
         -> sexp "bool"    (text $ show b)
 
        AInt  i         
         -> sexp "int"     (int i)

        AFloat d
         -> sexp "float"   (text $ show d)

        ANat  i
         -> sexp "nat"     (int i)

        ADecimal d 
         -> sexp "decimal" (text $ show d)

        AText str
         -> sexp "text"    (text $ show str)

        ATime str
         -> sexp "time"    (text $ show str)


-- Paths ----------------------------------------------------------------------
ppPath :: Path -> Doc
ppPath (Path ixs _ixts)
 = parens $   text "path"
          <+> (hsep $ map ppIx ixs)

ppIx :: Ix -> Doc
ppIx ix
 = case ix of
        IField  n       -> parens $ text "ifield"  <+> (text $ show n)
        ITree   t       -> parens $ text "itree"   <+> ppTuple t
        IForest n       -> parens $ text "iforest" <+> (text $ show n)



