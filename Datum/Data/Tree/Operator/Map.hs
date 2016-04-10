
module Datum.Data.Tree.Operator.Map
        ( mapTreesOfTree
        , mapTreesOfForest
        , mapForestsOfTree
        , mapForestOfTree

        , applyTreesOfForest
        , applyForestsOfTree)
where
import Datum.Data.Tree.Operator.Cast
import Datum.Data.Tree.Operator.Path
import Datum.Data.Tree.Compounds
import Datum.Data.Tree.Exp


-- Mapping ----------------------------------------------------------------------------------------
-- | Apply a per-tree function to every sub-tree of a tree.
mapTreesOfTree   :: (Path -> Tree c -> Tree c') -> Path -> Tree c -> Tree 'X
mapTreesOfTree f path tree
        = mapForestsOfTree (mapTreesOfForest f) path tree


-- | Apply a per-tree-function to every sub-tree of a forest.
mapTreesOfForest :: (Path -> Tree c -> Tree c') -> Path -> Forest c -> Forest 'X
mapTreesOfForest f path forest
 = applyTreesOfForest
        (map (\tree -> f (enterTree tree path) tree))
        forest


-- | Apply a per-forest function to every sub-forest of a tree.
mapForestsOfTree :: (Path -> Forest c -> Forest c') -> Path -> Tree c -> Tree 'X
mapForestsOfTree f path tree
 = applyForestsOfTree 
        (map (\forest -> f (enterForest forest path) forest)) 
        tree


-- | Apply a function to the named sub-forest of a tree.
mapForestOfTree  
        :: Name 
        -> (Path -> Forest c -> Forest c')
        -> Path  -> Tree   c -> Tree 'X

mapForestOfTree name f path tree
 =  flip applyForestsOfTree tree
 $  \forests
 -> map (\forest -> if nameOfForest forest == name
                        then weakenForest $ f (enterForest forest path) forest
                        else weakenForest forest)
 $  forests


-- Application ------------------------------------------------------------------------------------
-- | Apply a function to the list of sub-trees of a forest.
-- 
--   * The worker function can change the type of the trees,
--     provided the result trees all have the same type.
--
applyTreesOfForest :: ([Tree c] -> [Tree c']) -> Forest c -> Forest 'X
applyTreesOfForest f forest
 = let  
        trees   = treesOfForest forest
        trees'  = f trees

   in   case trees' of
         []       -> forestOfTrees (typeOfForest forest) trees'
         (t0 : _) -> forestOfTrees (typeOfTree   t0)     trees'
 

-- | Apply a function to the list of sub-forests of a tree.
applyForestsOfTree :: ([Forest c] -> [Forest c']) -> Tree c -> Tree 'X
applyForestsOfTree f
        (Tree (B k0 gs0) (BT n0 kt0 bts0))
 = let
        (gs1, bts1)
                = unzip
                $ map     takeForest
                $ f
                $ zipWith 
                        Forest 
                        (unboxes gs0)
                        (unboxes bts0)

   in   Tree    (B  k0     $ boxes gs1) 
                (BT n0 kt0 $ boxes bts1)