
module Datum.Data.Tree.Codec.Chrome where
import Datum.Data.Tree.Exp
import Text.PrettyPrint.Leijen
import Prelude                                  hiding ((<$>))
import qualified Data.Repa.Array                as A
import qualified Data.Repa.Scalar.Date32        as Date32

-- Trees-----------------------------------------------------------------------
ppTree :: Tree c -> Doc

ppTree (Tree (B k xssSub) (BT _n _kt bts))
 | A.length bts == 0
 =      text ". " <> ppTuple k

 | otherwise
 =      text "* " <> ppTuple k
 <$>    (vsep   $ map ppForest 
                $ zipWith makeForest 
                        (unboxes xssSub )
                        (unboxes bts))


ppForest :: Forest c -> Doc

ppForest (Forest (G _ bs) bt@(BT name kt _))
 | A.length bs == 0
 =      text "+ " <> text name <+> text "~" <+> ppTupleType kt

 | otherwise
 =      text "+ " <> text name <+> text "~" <+> ppTupleType kt
 <>     (nest 4 $ line <> vsep (map ppTree [Tree b bt | Box b <- A.toList bs]))


ppBranch :: Branch -> Doc
ppBranch (B t gs)
        | A.length gs == 0
        = text ". " <> ppTuple t

        | A.length gs           == 1
        , Just (Box (G _ bs))   <- A.head gs
        , A.length bs           == 0
        = text ". " <> ppTuple t

        | otherwise
        =  text "* " <> ppTuple t
        <> (nest 4 $ line <> vsep (map ppGroup $ unboxes gs))


ppGroup :: Group -> Doc
ppGroup (G _ bs)
        = vsep 
        $ map ppBranch 
        $ [b | Box b <- A.toList bs]


-- Keys -----------------------------------------------------------------------
ppKeyList :: [Key 'O] -> Doc
ppKeyList ks
 = vsep $ map ppKey ks


ppKey :: Key 'O -> Doc
ppKey (Key (T as) (TT nts))
 = parens 
 $ hcat $ punctuate (text ", ")
 $ zipWith ppAT (unboxes as) (A.toList nts)
 where  
        ppAT atom (Box name :*: Box ty)
         =   text name 
         <>  text ":" <+> ppAtomType ty
         <+> text "=" <+> ppAtom     atom


-- | Pretty print a key with field names, but no field types.
ppKeyNamed :: Key 'O -> Doc
ppKeyNamed (Key (T as) (TT nts))
        = parens 
        $ hcat $ punctuate (text ", ") 
        $ zipWith ppAT (unboxes as) (A.toList nts)

 where  
        ppAT atom (Box name :*: _)
         =   text name 
         <+> text "=" <+> ppAtom     atom


-- | Pretty print a `Tuple`.
ppTuple :: Tuple -> Doc
ppTuple (T as)
 = parens $ hcat (punctuate (text ", ") 
                 (map ppAtom $ unboxes as))


-- | Pretty print a `TupleType`.
ppTupleType :: TupleType -> Doc
ppTupleType (TT nts)
 = parens $ hcat (punctuate (text ", ") 
                 (map ppNameType $ A.toList nts))
 where  
        ppNameType (Box name :*: Box ty)
         = text name <> text ":" <+> ppAtomType ty


-- Atoms ----------------------------------------------------------------------
ppAtomType :: AtomType -> Doc
ppAtomType at
 = case at of
        ATUnit          -> text "Unit"
        ATBool          -> text "Bool"
        ATInt           -> text "Int"
        ATFloat         -> text "Float"
        ATNat           -> text "Nat"
        ATDecimal       -> text "Decimal"
        ATText          -> text "Text"
        ATTime          -> text "Time"
        ATDate          -> text "Date"


ppAtom :: Atom -> Doc
ppAtom aa
 = case aa of
        AUnit           -> text "()"
        ABool b         -> text $ show b
        AInt  i         -> int i
        AFloat d        -> text $ show d
        ANat  i         -> int i
        ADecimal d      -> text $ show d
        AText str       -> text $ show str
        ATime str       -> text str

        ADate d
         -> let (yy, mm, dd)     = Date32.unpack d
            in  text "d'"
                <> int yy <> text "-" 
                <> int mm <> text "-" 
                <> int dd
