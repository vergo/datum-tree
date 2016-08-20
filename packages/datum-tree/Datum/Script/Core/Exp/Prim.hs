{-# LANGUAGE UndecidableInstances #-}
module Datum.Script.Core.Exp.Prim where
import Datum.Script.Kernel.Exp.Generic
import Data.Text                                        (Text)
import qualified Datum.Script.Kernel.Exp.Prim           as K
import qualified Datum.Script.Kernel.Exp.Compounds      as K
import qualified Datum.Script.Kernel.Exp.Bind           as K
import qualified Datum.Data.Tree.Exp                    as T



---------------------------------------------------------------------------------------------------
-- | Primitive objects in the core language.
data GCPrim x
        -- Kinds  (level 2)
        = PKAtom                        -- ^ Kind of atom types.

        -- Types  (level 1)
        | PTList                        -- ^ List type constructor.

        | PTName                        -- ^ Name type.
        | PTNum                         -- ^ Supertype of number types.

        | PTForest                      -- ^ Datum forest type.
        | PTTree                        -- ^ Datum tree type.
        | PTTreePath                    -- ^ Datum tree path type.

        | PTFilePath                    -- ^ File path type.

        | PTAtom     T.AtomType         -- ^ Atom types.
 
        -- Values (level 0)
        | PVName     Text               -- ^ Field or branch name.
        | PVList     x [x]              -- ^ List of elements of the given type.

        | PVForest   (T.Forest 'T.O)    -- ^ Checked datum forest.
        | PVTree     (T.Tree   'T.O)    -- ^ Checked datum tree.
        | PVTreePath [Text]             -- ^ Datum tree path.

        | PVFilePath FilePath           -- ^ File path.

        | PVAtom     T.Atom             -- ^ Atomic Values.
        | PVOp       PrimOp             -- ^ Primitive operators with the given type arguments.


-- Primitive operators.
data PrimOp
        = PPNeg                         -- ^ Negation.
        | PPAdd                         -- ^ Addition.
        | PPSub                         -- ^ Subtraction.
        | PPMul                         -- ^ Multiplication.
        | PPDiv                         -- ^ Division

        | PPEq                          -- ^ Equality.
        | PPGt                          -- ^ Greater-than.
        | PPGe                          -- ^ Greater-than-equal.
        | PPLt                          -- ^ Less-than.
        | PPLe                          -- ^ Less-than-equal.

        | PPArgument                    -- ^ Get the value of a script argument.
        | PPLoad                        -- ^ Load  a value from the file system.
        | PPStore                       -- ^ Store a value to the file system.
        | PPInitial                     -- ^ Select the initial n branches of each subtree.
        | PPFinal                       -- ^ Select the final n branches of each subtree.
        | PPSample                      -- ^ Sample n intermediate branches of each subtree.
        | PPGroup                       -- ^ Group branches by given key field.
        | PPGather                      -- ^ Gather branches of a tree into sub trees.
        | PPFlatten                     -- ^ Flatten branches.
        | PPRenameFields                -- ^ Rename fields of key.
        | PPPermuteFields               -- ^ Permute fields of a key.

        | PPAt                          -- ^ Apply a per-tree function at the given path.
        | PPOn                          -- ^ Apply a per-forest function at the given path. 

        | PPPrint                       -- ^ Print an object to the console.
        deriving Eq

-- | Table of names of primitive operators.
namesOfPrimOps :: [(PrimOp, String)]
namesOfPrimOps
 =      [ (PPNeg,               "neg#")
        , (PPAdd,               "add#")
        , (PPSub,               "sub#")
        , (PPMul,               "mul#")
        , (PPDiv,               "div#")
        , (PPEq,                "eq#")
        , (PPGt,                "gt#")
        , (PPGe,                "ge#")
        , (PPLt,                "lt#")
        , (PPLe,                "le#")
        , (PPArgument,          "argument#")
        , (PPLoad,              "load#")
        , (PPStore,             "store#")
        , (PPInitial,           "initial#")
        , (PPFinal,             "final#")
        , (PPSample,            "sample#")
        , (PPGroup,             "group#")
        , (PPGather,            "gather#")
        , (PPFlatten,           "flatten#")
        , (PPRenameFields,      "rename-fields#")
        , (PPPermuteFields,     "permute-fields#")
        , (PPAt,                "at#")
        , (PPOn,                "on#")
        , (PPPrint,             "print#") ]


-- | Tables of primitive operators of names.
primOpsOfNames :: [(String, PrimOp)]
primOpsOfNames 
 = [ (name, op) | (op, name) <- namesOfPrimOps]


deriving instance Show x => Show (GCPrim x)
deriving instance Show PrimOp

type GExpStd l n
 =      ( GXPrim l  ~ K.GPrim (GExp l)
        , GXFrag l  ~ GCPrim  (GExp l)
        , GXBind l  ~ K.Bind  n
        , GXBound l ~ K.Bound n)


---------------------------------------------------------------------------------------------------
-- | Yield the type of the given primitive.
typeOfPrim 
        :: GExpStd l n
        => GCPrim (GExp l)
        -> GExp   l

typeOfPrim pp
 = case pp of
        -- Types of Kinds
        PKAtom          -> K.XType 2

        -- Types of Types
        PTNum           -> K.XType 1
        PTList          -> K.XType 1 ~~> K.XType 1

        PTName          -> K.XType 1

        PTForest        -> K.XType 1
        PTTree          -> K.XType 1
        PTTreePath      -> K.XType 1

        PTFilePath      -> K.XType 1

        PTAtom _        -> K.XType 1

        -- Types of Values
        PVName _        -> XTName
        PVList t _      -> XTList t

        PVForest _      -> XTForest
        PVTree   _      -> XTTree
        PVTreePath  _   -> XTTreePath

        PVFilePath  _   -> XTFilePath

        PVAtom a        -> XFrag (PTAtom (typeOfAtom a))
        PVOp   op       -> typeOfOp op


-- | Yield the type of the given atom.
typeOfAtom :: T.Atom -> T.AtomType
typeOfAtom aa
 = case aa of
        T.AUnit{}       -> T.ATUnit
        T.ABool{}       -> T.ATBool
        T.AInt{}        -> T.ATInt
        T.AFloat{}      -> T.ATFloat
        T.ANat{}        -> T.ATNat
        T.ADecimal{}    -> T.ATDecimal
        T.AText{}       -> T.ATText
        T.ATime{}       -> T.ATTime


-- | Yield the type of the given primop.
typeOfOp :: GExpStd l n
         => PrimOp -> GExp l
typeOfOp op
 = case op of
        PPNeg           -> error "typeOfOp: finish me"
        PPAdd           -> error "typeOfOp: finish me"
        PPSub           -> error "typeOfOp: finish me"
        PPMul           -> error "typeOfOp: finish me"
        PPDiv           -> error "typeOfOp: finish me"

        PPEq            -> error "typeOfOp: finish me"
        PPGt            -> error "typeOfOp: finish me"
        PPGe            -> error "typeOfOp: finish me"
        PPLt            -> error "typeOfOp: finish me"
        PPLe            -> error "typeOfOp: finish me"

        PPArgument      -> XTText        ~> K.XTS XTText

        PPLoad          -> XTFilePath    ~> K.XTS XTTree
        PPStore         -> XTFilePath    ~> XTTree ~> K.XTS K.XTUnit
        PPInitial       -> XTNat         ~> XTTree ~> XTTree
        PPFinal         -> XTNat         ~> XTTree ~> XTTree
        PPSample        -> XTNat         ~> XTTree ~> XTTree
        PPGroup         -> XTName        ~> XTTree ~> XTTree
        PPGather        -> XTTreePath    ~> XTTree ~> XTTree
        PPFlatten       -> XTTree        ~> XTTree
        PPRenameFields  -> XTList XTName ~> XTTree ~> XTTree
        PPPermuteFields -> XTList XTName ~> XTTree ~> XTTree

        PPAt            -> XTList XTName ~> (XTTree   ~> XTTree)   ~> XTTree ~> XTTree
        PPOn            -> XTList XTName ~> (XTForest ~> XTForest) ~> XTTree ~> XTTree

        PPPrint
         -> K.makeXForall K.XKData K.XKData 
                $ \u -> u ~> K.XTS K.XTUnit


-- | Yield the arity of a primitive.
arityOfPrim :: GCPrim x -> Int
arityOfPrim pp
 = case pp of
        PVOp op         -> arityOfOp op
        _               -> 0


-- | Yield the arity of a primitive operator.
arityOfOp :: PrimOp -> Int
arityOfOp op
 = case op of
        PPNeg           -> 1
        PPAdd           -> 2
        PPSub           -> 2
        PPMul           -> 2
        PPDiv           -> 2

        PPEq            -> 2
        PPGt            -> 2
        PPGe            -> 2
        PPLt            -> 2
        PPLe            -> 2

        PPArgument      -> 1
        PPLoad          -> 1
        PPStore         -> 2
        PPInitial       -> 2
        PPFinal         -> 2
        PPSample        -> 2
        PPGroup         -> 2
        PPGather        -> 2
        PPFlatten       -> 1
        PPRenameFields  -> 2
        PPPermuteFields -> 2

        PPAt            -> 3
        PPOn            -> 3

        PPPrint         -> 1

---------------------------------------------------------------------------------------------------
-- Types
pattern XTList a        = XApp (XFrag PTList) a

pattern XTName          = XFrag PTName
pattern XTForest        = XFrag PTForest
pattern XTTree          = XFrag PTTree
pattern XTTreePath      = XFrag PTTreePath
pattern XTFilePath      = XFrag PTFilePath

pattern XTBool          = XFrag (PTAtom T.ATBool)
pattern XTInt           = XFrag (PTAtom T.ATInt)
pattern XTFloat         = XFrag (PTAtom T.ATFloat)
pattern XTNat           = XFrag (PTAtom T.ATNat)
pattern XTDecimal       = XFrag (PTAtom T.ATDecimal)
pattern XTText          = XFrag (PTAtom T.ATText)
pattern XTTime          = XFrag (PTAtom T.ATTime)

-- Values
pattern XName     n     = XFrag (PVName     n)
pattern XList     t xs  = XFrag (PVList     t xs)
pattern XForest   f     = XFrag (PVForest   f)
pattern XTree     t     = XFrag (PVTree     t)
pattern XTreePath ts    = XFrag (PVTreePath ts)
pattern XFilePath fp    = XFrag (PVFilePath fp)

pattern XBool     x     = XFrag (PVAtom (T.ABool    x))
pattern XInt      x     = XFrag (PVAtom (T.AInt     x))
pattern XFloat    x     = XFrag (PVAtom (T.AFloat   x))
pattern XNat      x     = XFrag (PVAtom (T.ANat     x))
pattern XDecimal  x     = XFrag (PVAtom (T.ADecimal x))
pattern XText     x     = XFrag (PVAtom (T.AText    x))
pattern XTime     x     = XFrag (PVAtom (T.ATime    x))

pattern XArgument       = XFrag (PVOp PPArgument)
pattern XLoad           = XFrag (PVOp PPLoad)
pattern XStore          = XFrag (PVOp PPStore)
pattern XInitial        = XFrag (PVOp PPInitial)
pattern XFinal          = XFrag (PVOp PPFinal)
pattern XSample         = XFrag (PVOp PPSample)
pattern XGroup          = XFrag (PVOp PPGroup)
pattern XGather         = XFrag (PVOp PPGather)
pattern XFlatten        = XFrag (PVOp PPFlatten)
pattern XRenameFields   = XFrag (PVOp PPRenameFields)
pattern XPermuteFields  = XFrag (PVOp PPPermuteFields)

pattern XAt             = XFrag (PVOp PPAt)
pattern XOn             = XFrag (PVOp PPOn)


(~>)    ::  (GXPrim l ~ K.GPrim (GExp l))
        =>  GExp l -> GExp l -> GExp l
(~>) a b  = XApp (XApp (XPrim (K.PFun 1)) a) b
infixr ~>


(~~>)   ::  (GXPrim l ~ K.GPrim (GExp l))
        =>  GExp l -> GExp l -> GExp l
(~~>) a b = XApp (XApp (XPrim (K.PFun 2)) a) b
infixr ~~>
