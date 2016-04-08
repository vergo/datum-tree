
module Datum.Data.Tree.Check
        ( checkBranchType
        , checkKeyType

        , checkTree,    checkTree'
        , checkBranch

        , checkForest
        , checkGroup

        , checkKey,     checkKey'
        , checkTuple

        , checkAtom

        , Error (..)
        , ppError)
where
import Datum.Data.Tree.Check.Error
import Datum.Data.Tree.Exp
import Control.Monad
import Control.Monad.Except
import qualified Data.List              as L


-------------------------------------------------------------------------------
-- | Check that a shape is well formed.
checkBranchType :: PathType -> BranchType -> Either Error ()
checkBranchType 
        (PathType pts)
        bt@(BT _n tKey subs)
 = do
        let pts'        = ITForest bt : pts
        let tPath'      = PathType pts'

        -- Check the tuple type.
        checkKeyType tPath' tKey

        -- Check that sub dimension names do not clash.
        let nsSub       = [n | BT n _ _ <- subs]
        when (length nsSub /= length (L.nub nsSub))
         $ throwError $ ErrorClashSubDim tPath' nsSub

        -- Check the sub dimension shapes.
        mapM_ (checkBranchType tPath') subs


-- | Check that a tuple type is well formed.
checkKeyType :: PathType -> TupleType -> Either Error ()
checkKeyType path (TT nts)
 = do
        -- Check that field names do not clash.
        let nsField     = [n | (n, _)   <- nts]
        when (length nsField /= length (L.nub nsField))
         $ throwError $ ErrorClashField path nsField


-------------------------------------------------------------------------------
-- | Check that a tree is well formed.
checkTree :: Tree c -> Either Error (Tree 'O)
checkTree tree 
 =      checkTree' mempty tree


-- | Check that a tree is well formed, at the given starting path.
checkTree' :: Path -> Tree c -> Either Error (Tree 'O)
checkTree' path (Tree branch branchType)
 = case checkBranch path branch branchType of
        Left err -> Left err
        Right () -> Right $ Tree branch branchType


-- | Check that a branch has the given branch type.
checkBranch :: Path -> Branch -> BranchType -> Either Error ()
checkBranch
        (Path ps pts) 
        (B key subs) bt@(BT name tKey@(TT _nts) tsSub)
 = do
        let ps'         = IForest name : ps
        let pts'        = ITForest bt  : pts
        let path'       = Path ps' pts'
        let tPath'      = PathType pts'

        -- Check the tuple type.
        checkKeyType tPath' tKey 

        -- Check the key matches its type.
        checkTuple   path'  key tKey

        -- Check that the number of sub trees matches the number of
        -- sub dimensions.
        when (length subs /= length tsSub)
         $ throwError $ ErrorArityDim path' subs tsSub

        -- Check that sub dimension names do not clash.
        let nsSub       = [n | BT n _ _ <- tsSub]
        when (length nsSub /= length (L.nub nsSub))
         $ throwError $ ErrorClashSubDim tPath' nsSub

        -- Check each of the sub trees.
        zipWithM_ (checkGroup path') subs tsSub


-------------------------------------------------------------------------------
-- | Check that a forest is well formed.
checkForest  :: Forest c -> Either Error (Forest 'O)
checkForest forest
        = checkForest' mempty forest


-- | Check that a forest is well formed, at the given starting path.
checkForest' :: Path -> Forest c -> Either Error (Forest 'O)
checkForest' path (Forest bs bt)
 = case checkGroup path bs bt of
        Left err        -> Left err
        Right ()        -> Right $ Forest bs bt


-- | Check that all the branches in a group
--   have the specified shape.
checkGroup :: Path -> Group -> BranchType -> Either Error ()
checkGroup path (G _n bs) shape
 = do   mapM_ (\b -> checkBranch path b shape) bs


-------------------------------------------------------------------------------
-- | Check that a key is well formed.
checkKey  :: Key c -> Either Error (Key 'O)
checkKey key
        = checkKey' mempty key


-- | Check that a key is well formed, at the given starting path.
checkKey' :: Path -> Key c -> Either Error (Key 'O)
checkKey' path (Key t tt)
 = case checkTuple path t tt of
        Left err        -> Left err
        Right ()        -> Right $ Key t tt


-- | Check that a tuple has the given type.
checkTuple :: Path -> Tuple -> TupleType -> Either Error ()
checkTuple path@(Path _ps _pts) (T fields) (TT nts)
 = do   
        -- Check that the number of fields matches the tuple type.
        when (length fields /= length nts)
         $ throwError $ ErrorArityTuple path fields nts

        zipWithM_ 
                (\  field (_name, tField)
                 ->     checkAtom path field tField)
                fields nts


-------------------------------------------------------------------------------
-- | Check that an atom has the given type.
checkAtom  :: Path -> Atom -> AtomType -> Either Error ()
checkAtom path lit tp
 = case (lit, tp) of
        (AUnit,         ATUnit)         -> return ()
        (ABool _,       ATBool)         -> return ()
        (AInt _,        ATInt)          -> return ()
        (AFloat _,      ATFloat)        -> return ()
        (ANat _,        ATNat)          -> return ()
        (ADecimal _,    ATDecimal)      -> return ()
        (AText _,       ATText)         -> return ()
        (ATime _,       ATTime)         -> return ()
        _ -> throwError $ ErrorAtom path lit tp

