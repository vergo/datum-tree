
module Datum.Data.Tree.Operators
        ( -- * Projections
          nameOfTree
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
import Datum.Data.Tree.Exp
import Datum.Data.Tree.Compounds
import qualified Data.List              as L
import qualified Data.Repa.Array        as A


-- Paths ------------------------------------------------------------------------------------------
-- | Extend a path to record that we have entered into this sub-tree.
enterTree :: Tree c -> Path -> Path 
enterTree   (Tree (B k0 _) (BT _n0 kt0 _)) (Path ps pts)
 = Path (ITree k0 : ps) (ITTree kt0 : pts)


-- | Extend a path to record that we have entered into this sub-forest.
enterForest :: Forest c -> Path -> Path
enterForest (Forest _ bt@(BT n0 _ _bts)) (Path ps pts)
 = Path (IForest n0 : ps) (ITForest bt : pts)


-- | Check if a path includes a forest with the give name.
pathIncludesName :: Name -> Path -> Bool
pathIncludesName name (Path ps _pts)
 = let  ns      = [n | IForest n <- ps]
   in   elem name ns


-- | Check if we're on the path defined by the given names.
onPath :: [Name] -> Path -> Bool
onPath ns (Path ps pts)
 = onPath' ns (Path (reverse ps) (reverse pts))

onPath' _  (Path [] _)  = True
onPath' _  (Path _ [])  = True
onPath' [] _            = True
onPath' nn@(n : ns) (Path (p : ps) (_pt : pts))
 = case p of
        IForest n'
         | n == n'      -> onPath' ns (Path ps pts)
         | otherwise    -> False

        _               -> onPath' nn (Path ps pts)


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


-- Reduction --------------------------------------------------------------------------------------
-- | Reduce all sub-trees in the given tree.
reduceTree :: (Path -> a -> Tree c -> a) -> Path -> a -> Tree c -> a
reduceTree f 
        (Path ps pts) 
        acc tree@(Tree (B k0 _xssSub0) (BT _n0 kt0 _tsSub0))
 = let  
        path'   = Path (ITree k0 : ps) (ITTree kt0 : pts)

   in   L.foldl' (reduceForest f path') (f path' acc tree) 
         $ forestsOfTree tree


-- | Reduce all sub-trees in the given forest.
reduceForest :: (Path -> a -> Tree c -> a) -> Path -> a -> Forest c -> a
reduceForest f path acc (Forest (G _n bs) bt)
 =      L.foldl' (\acc' b -> reduceTree f path acc' (Tree b bt))
                 acc 
                 (map unbox $ A.toList bs)


-- | Get a list of all tuples in the given tree.
keysOfTree :: Tree c -> [Key c]
keysOfTree tree
 = let  
        paths   = reduceTree (\p acc _ -> acc ++ [p]) mempty [] tree
        ixs     = [ Key (T  (reverse $ concat 
                                [ reverse as 
                                        | ITree  (T as) <- ps' ]))

                        (TT     $ A.fromList 
                                $ reverse $ concat
                                [ reverse $ A.toList nts
                                        | ITTree (TT nts) <- pts'])

                  | Path ps' pts' <- paths]
  in    ixs


-- | Get the size of a tree, in number of branches, including the root branch.
sizeOfTree :: Tree c -> Int
sizeOfTree tree
 = reduceTree (\_ n _ -> n + 1) mempty 0 tree   


-- Filter -----------------------------------------------------------------------------------------
-- | Filter a tree by keeping only the sub-trees that match
--   the given predicate. 
--
--   * This is a shallow filter. We only consider the direct sub-trees of
--     the provided one.
--
filterTree :: (Path -> Tree c -> Bool) -> Path -> Tree c -> Tree c
filterTree p path tree 
 = promiseTree
 $ applyForestsOfTree 
        (\ forests 
        -> map  (\forest 
                -> filterTreesOfForest p 
                        (enterForest forest path) 
                        forest)
                forests)
        tree


-- | Filter a tree by keeping only the sub-forests that match
--   the given predicate.
filterForestsOfTree :: (Path -> Forest c -> Bool) -> Path -> Tree c -> Tree c
filterForestsOfTree p path tree
 = promiseTree
 $ applyForestsOfTree 
        (filter (\ forest 
                -> p (enterForest forest path) forest))
        tree


-- | Filter a forest by keeping only the sub-trees that match
--   the given predicate.
filterTreesOfForest :: (Path -> Tree c -> Bool) -> Path -> Forest c -> Forest c
filterTreesOfForest p path forest 
 = promiseForest
 $ applyTreesOfForest
        (filter (\ tree
                -> p (enterTree tree path) tree))
        forest


-- Slice ------------------------------------------------------------------------------------------
-- | Slice a tree by keeping only the sub-forests that satisfy the given
--   predicate.
-- 
--   * This is a deep filter, we traverse through the whole tree removing
--     forests that do not match the given predicate.
--
--   * When the predicate returns `False` for a particular forest,
--     both data and meta-data for that forest are removed from the tree.
--
sliceTree :: (Path -> Forest c -> Bool) -> Path -> Tree c -> Tree c
sliceTree p path0 tree0 
 = let path1    = enterTree tree0 path0
   in  promiseTree 
        $ applyForestsOfTree
                (\ forests
                -> map  (\ forest
                        -> let path2    = enterForest forest path1
                           in  applyTreesOfForest 
                                (\ trees
                                -> map  (\ tree 
                                        -> let path3   = enterTree tree path2
                                           in  sliceTree p path3 tree) 
                                        trees)
                                forest)
                $ filter
                        (\ forest 
                        -> let path2    = enterForest forest $ enterTree tree0 path0
                           in  p path2 forest)
                $ forests)
                tree0


-- | Like `sliceTree`, but keep only the forests on the path with the given names.
sliceTreeWithNames :: [Name] -> Tree c -> Tree c
sliceTreeWithNames ns tree
 = sliceTree (\p _ -> onPath ns p) mempty tree


-- Traversal --------------------------------------------------------------------------------------
-- | Bottom-up traversal of a tree.
--
--   * This does not check that the transformed trees are well
--     formed during traversal.
--
traverseTree :: (Path -> Tree 'X -> Tree c) -> Path -> Tree c' -> Tree 'X
traverseTree f  
        (Path ps pts)
        (Tree (B k0 xssSub0) (BT n0 kt0 tsSub0))
 = let
        path'   = Path (ITree k0 : ps) (ITTree kt0 : pts)

        (xssSub, tsSub)
                = unzip
                $ [ let Forest xsSub' tSub'
                                = mapTreesOfForest f path'
                                $ mapTreesOfForest (traverseTree f) path'
                                $ Forest xsSub tSub

                    in  (xsSub', tSub')

                        | xsSub  <- unboxes xssSub0
                        | tSub   <- unboxes tsSub0 ]

   in   Tree    (B k0      $ boxes xssSub) 
                (BT n0 kt0 $ boxes tsSub)


-- Limiting ---------------------------------------------------------------------------------------

------------------------
class Initial a where
 -- | Take only the initital 'n' trees of every Forest.
 initial :: Int -> a -> a

instance Initial (Tree c) where
 initial n (Tree b bt)
  = Tree (initial n b) bt

instance Initial (Forest c) where
 initial n (Forest g bt)
  = Forest (initial n g) bt

instance Initial Branch where
 initial n (B t gs)
  = B t $ A.map (fmap (initial n)) gs

instance Initial Group where
 initial n (G name bs)
  = let iStart   = 0
        iEnd     = max n (A.length bs)
        Just bs' = A.slice iStart iEnd bs
    in  G name  $ A.map (box . initial n . unbox) bs'


------------------------
class Final a where
 -- | Take only the final 'n' trees of every Forest.
 final :: Int -> a -> a

instance Final (Tree c) where
 final n (Tree b bt)
  = Tree (final n b) bt

instance Final (Forest c) where
 final n (Forest g bt)
  = Forest (final n g) bt

instance Final Branch where
 final n (B t gs)
  = B t $ A.map (box . final n . unbox) gs

instance Final Group where
 final n (G name bs)
  = let iStart   = max 0 (A.length bs - n)
        iLen     = max n (A.length bs)
        Just bs' = A.slice iStart iLen bs

    in  G name  $ A.map (box . final n . unbox) bs'


-------------------------
class Sample a where
 -- | Sample each forest so the result contains at most the given
 --   number of trees. The returned trees are spaced regularly, 
 --   for example, to return 5 trees from a 20 tree group, we take
 --   every fourth one.
 sample :: Int -> a -> a

instance Sample (Tree c) where
 sample n (Tree b bt)
  = Tree (sample n b) bt

instance Sample (Forest c) where
 sample n (Forest g bt)
  = Forest (sample n g) bt

instance Sample Branch where
 sample n (B t gs)
  = B t $ A.map (box . sample n . unbox) gs

instance Sample Group where
 sample _ (G name bb)
  | A.length bb == 0
  = G name A.empty

 sample 0 (G name _)
  = G name A.empty

 sample 1 (G name bs)
  | Just bFirst <- A.first bs
  = G name $ A.singleton bFirst

 sample n (G name bb)
  = let 
        Just bFirst = A.head bb
        Just bLast  = A.last bb
        Just bs     = A.tail bb

        len     = max 0 (A.length bb)

        dec     = len `div` (max 1 n)

        mids    = boxes
                $ take   (n - 2)
                $ map    snd
                $ filter (\(i, _) -> i `mod` dec == 0)
                $ zip [1..] 
                $ unboxes bs

    in  G name  $ A.map (box . sample n . unbox)
                $ A.concat
                $ A.fromList [A.singleton bFirst, mids, A.singleton bLast]


---------------------------------------------------------------------------------------------------
-- | Promise that this tree is well typed.
promiseTree :: Tree c -> Tree c'
promiseTree (Tree b bt) = Tree b bt


-- | Promise that this forest is well typed.
promiseForest :: Forest c -> Forest c'
promiseForest (Forest bs bt) = Forest bs bt

