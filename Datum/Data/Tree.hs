
-- | Datum data trees.
--
--   * To construct literal trees use either 
--     the     "Datum.Data.Tree.Exp" 
--     or the  "Datum.Data.Tree.SExp" modules.
--
--   * To access the internal representation use
--     the "Datum.Data.Tree.Compounds" module.
--
module Datum.Data.Tree
        ( -- * Objects
          Tree
        , Forest
        , Key
        , Element
        , Atom
        , Name

          -- * Checking
        , Checked (..)
        , check
        , check'

          -- * Predicates
        , isLeaf

          -- * Projections
          -- ** Names
        , takeName
        , hasName

          -- ** Meta-data
        , takeMeta

          -- ** Data
        , takeData

          -- ** Trees
        , takeTrees

          -- ** Forests
        , takeForests

          -- ** Keys
        , takeKey
        , hasKey

          -- ** Fields
        , takeFieldNames

          -- ** Elements
        , takeElements
        , takeElement
        , hasElement
        , extractElement

          -- ** Atoms
        , takeAtoms
        , takeAtom

          -- * Operators

          -- ** Paths
        , enterTree
        , enterForest
        , pathIncludesName
        , onPath 

          -- ** Renaming
        , renameFields

          -- ** Mapping
        , mapTrees
        , mapTrees'

        , mapForests
        , mapForests'
        , mapForest'

          -- ** Filtering
        , filterTrees
        , filterTrees'

        , filterForests
        , filterForests'

          -- ** Reducing
        , reduceTree
        , reduceForest

        , keysOfTree
        , sizeOfTree
        
          -- ** Slicing
        , sliceTree
        , sliceTreeWithNames

          -- ** Grouping
        , groupForest

          -- ** Gathering
        , gatherTree

          -- ** Traversal
        , traverseTree

          -- ** Limiting
        , initial
        , final
        , sample)
where
import Datum.Data.Tree.Compounds
import Datum.Data.Tree.Operator
import Datum.Data.Tree.Check
import Datum.Data.Tree.Exp
