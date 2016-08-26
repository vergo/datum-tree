
module Datum.Script.Core.Eval.Prim.Base
        ( module Datum.Script.Core.Eval.Error
        , module Datum.Script.Core.Eval.Pretty
        , module Datum.Script.Core.Eval.State
        , module Datum.Script.Core.Eval.Value
        , module Datum.Script.Core.Exp
        , type Text
        , progress, failure, crash, stuck
        , takeXName
        , takeVNat)
where
import Datum.Script.Core.Eval.Env
import Datum.Script.Core.Eval.Error
import Datum.Script.Core.Eval.Pretty
import Datum.Script.Core.Eval.State
import Datum.Script.Core.Eval.Value
import Datum.Script.Core.Exp
import Data.Text                                        (Text)
import qualified Datum.Data.Tree                        as T
import qualified Data.Text                              as Text


-- | Signal that evaluation has progressed.
progress thunk  = return $ Right thunk


-- | Signal that evaluation has failed due to a runtime error.
failure  err    = return $ Left  err


-- | Signal that evalution has crashed because of some error in the interpreter.
--   This is an implementation error.
crash :: Monad m => m (Either Error a)
crash           = return $ Left (ErrorCore ErrorCoreCrash)


-- | Signal that evaluation has gotten stuck because we've found an ill-typed term.
--   This is a runtime type error in the user program.
stuck :: Monad m => m (Either Error a)
stuck           = return $ Left (ErrorCore ErrorCoreStuck)


-- | Take the name from an expression, if there is one.
takeXName :: Exp -> Maybe T.Name
takeXName xx
 = case xx of
        XAnnot _ x      -> takeXName x
        XName n         -> Just (Text.unpack n)
        _               -> Nothing


-- | Take a natural number from a value, if there is one.
--   This works for VNat and VInt.
takeVNat :: Value -> Maybe Int
takeVNat vv
 = case vv of
        VNat n          -> Just n
        VInt n | n >= 0 -> Just n
        _               -> Nothing
