
module Datum.Data.Tree.Exp
        ( -- * Objects
          Tree          (..)
        , Forest        (..)
        , Key           (..)
        , Checked       (..)
        , CheckMin

          -- * Meta-Data
        , Name
        , BranchType    (..)
        , TupleType     (..)
        , AtomType      (..)

          -- * Data
        , Group         (..)
        , Branch        (..)
        , Tuple         (..)
        , Atom          (..)

          -- * Paths
        , PathType      (..)
        , Path          (..)
        , IxType        (..)
        , Ix            (..)

          -- * Utils
        , Box           (..)
        , box,   unbox
        , boxes, unboxes

        , Option        (..)

        , (:*:)         (..))
where
import Data.Repa.Scalar.Box
import Data.Repa.Scalar.Option           
import Data.Repa.Scalar.Product
import Data.Repa.Array                  (Array)
import qualified Data.Repa.Array        as A


-- Objects --------------------------------------------------------------------
-- | Indication of whether an object's data has been checked against
--   the constraints in its meta-data.
--
data Checked
        = O     -- ^ Object has been checked.
        | X     -- ^ Object has not been checked.
        deriving (Show, Eq, Ord)

type family CheckMin (a :: Checked) (b :: Checked) where
  CheckMin O O = O
  CheckMin O X = X
  CheckMin X O = X
  CheckMin X X = X


-- | A tree contains both branch data and branch meta-data.
--
--   * The type constructor has a phantom parameter indicating
--     whether the data has been checked against the meta-data.
--
data Tree   (c :: Checked)
        -- | By using the raw constructor to build a tree you promise that
        --   the `Checked` parameter is valid.
        = Tree  !Branch         -- Tree data.
                !BranchType     -- Tree meta-data.
        deriving Show


-- | A forest contains a sequence of trees of the same type.
--
--   * The type constructor has a phantom parameter indicating 
--     whether the data has been checked against the meta-data.
--
data Forest (c :: Checked)
        -- | By using the raw constructor to build a forest you promise that
        --     the `Checked` parameter is valid.
        = Forest 
                !Group          -- A group of trees of the same type.
                !BranchType     -- The shared type of the trees.
        deriving Show


-- | A key contains tuple data and tuple meta-data.
--
--   * The type constructor has a phantom parameter indicating 
--     whether the data has been checked against the meta-data.
--
data Key (c :: Checked)
        -- | By using the raw constructor to build a ket you promise that
        --     the `Checked` parameter is valid.
        = Key   !Tuple          -- Key tuple value
                !TupleType      -- Key tuple type.
        deriving Show


-- Meta-data ------------------------------------------------------------------
-- | Branch type describes the structure of a branch.
data BranchType
        = BT    !Name                           -- Name of this dimension.
                !TupleType                      -- Tuple type.
                !(Array (Box BranchType))       -- Sub dimensions.
        deriving Show


-- | Named tuple types.
data TupleType
        = TT    !(Array (Box Name :*: Box AtomType))
        deriving Show


-- | Atom types.
data AtomType
        = ATUnit
        | ATBool
        | ATInt
        | ATFloat
        | ATNat
        | ATDecimal
        | ATText
        | ATTime
        deriving Show


-- Data -----------------------------------------------------------------------
-- | A group with a name and list of branches.
--  
--   * The name here is not strictly required by the representation as
--     in a typed tree the group name should match the corresponding
--     branch type name. However, including it makes it easier to debug 
--     problems situtations where the tree is not well typed.
--
data Group
        = G     !(Option Name)                  -- Group name.
                !(Array (Box Branch))           -- Data of trees in this group.
        deriving Show


-- | Branch with a key and forests of sub-branches.
data Branch
        = B     !Tuple                          -- Branch key tuple.
                !(Array (Box Group))            -- Sub groups of this tree.
        deriving Show 


-- | Tuple values.
data Tuple
        = T     !(Array (Box Atom))             -- Tuple field values.
        deriving Show


-- | Atomic values.
data Atom
        = AUnit
        | ABool         !Bool
        | AInt          !Int
        | AFloat        !Double
        | ANat          !Int
        | ADecimal      !Double
        | AText         !String
        | ATime         !String
        deriving Show


-- Names ----------------------------------------------------------------------
-- | Branch and field names.
type Name
        = String


-- Path -----------------------------------------------------------------------
data PathType
        = PathType  ![IxType]
        deriving Show


-- | Path to a particular element.
data Path
        = Path ![Ix] ![IxType]
        deriving Show


-- | Type of a path.
data IxType
        -- | The atom type of a field.
        = ITField       !AtomType

        -- | The tuple type of a tree.
        | ITTree        !TupleType

        -- | The branch type of a forest.
        | ITForest      !BranchType
        deriving Show   

data Ix
        -- | The field name of a field.
        = IField        !Name

        -- | The key of a tree.
        | ITree         !Tuple

        -- | The group name of a forest.
        | IForest       !Name
        deriving Show


instance Monoid Path where
 mempty = Path [] []
 mappend (Path ps1 pts1)    (Path ps2 pts2)
        = Path (ps1 ++ ps2) (pts1 ++ pts2)


-- Utils ----------------------------------------------------------------------
-- | Unpack an array of boxed things into a lazy list.
unboxes :: Array (Box a) -> [a]
unboxes arr = map unbox $ A.toList arr
{-# INLINE unboxes #-}


-- | Evaluate a a lazy list of things into an array.
boxes   :: [a] -> Array (Box a)
boxes ls    = A.fromList $ map box ls
{-# INLINE boxes #-}

