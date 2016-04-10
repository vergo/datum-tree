
module Datum.Data.Tree.Operator
        ( -- * Casts
          weakenTree
        , weakenForest

          -- * Projections
        , nameOfTree
        , nameOfForest

        , forestsOfTree
        , treesOfForest

          -- * Paths
        , enterTree
        , enterForest
        , pathIncludesName
        , onPath 

          -- * Mapping
        , mapTreesOfTree
        , mapTreesOfForest
        , mapForestsOfTree
        , mapForestOfTree

          -- * Reducing
        , reduceTree
        , reduceForest

        , keysOfTree
        , sizeOfTree

          -- * Filtering
        , filterTree
        , filterTreesOfForest
        , filterForestsOfTree

          -- * Slicing
        , sliceTree
        , sliceTreeWithNames

          -- * Traversal
        , traverseTree

          -- * Limiting
        , Initial (..)
        , Final   (..)
        , Sample  (..))
where
import Datum.Data.Tree.Operator.Cast
import Datum.Data.Tree.Operator.Map
import Datum.Data.Tree.Operator.Path
import Datum.Data.Tree.Operator.Filter
import Datum.Data.Tree.Operator.Limit
import Datum.Data.Tree.Operator.Reduce
import Datum.Data.Tree.Operator.Slice
import Datum.Data.Tree.Operator.Traverse
import Datum.Data.Tree.Compounds

