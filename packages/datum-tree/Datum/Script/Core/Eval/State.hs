
-- | Evaluation state for Datum Scripts.
module Datum.Script.Core.Eval.State where
import Datum.Script.Core.Eval.Value
import Datum.Script.Core.Eval.Env               (Env)
import Datum.Script.Core.Exp
import Data.Default
import Data.Text                                (Text)
import qualified Datum.Script.Core.Eval.Env  as Env


-------------------------------------------------------------------------------
-- | Evaluation state of an expression,
--   for a CEK-like machine.
data State
        = State
        { -- | World that the machine is executing in.
          stateWorld    :: World

          -- | Environment.
        , stateEnv      :: !Env

          -- | Current context (Kontinuation).
        , stateContext  :: !Context

          -- | Current focus of evaluation (Control).
        , stateControl  :: !Control
        }

deriving instance Show State

stateInit :: World -> Exp -> State
stateInit world xx
        = State
        { stateWorld    = world
        , stateEnv      = Env.empty
        , stateContext  = ContextNil 
        , stateControl  = ControlExp xx }


-------------------------------------------------------------------------------
-- | Information about the state of the outside world that the machine
--   is executing in. This is static configuration information like the 
--   command line arguments that were passed to the script.
data World
        = World
        { -- | Command line arguments passed to the script.
          worldArguments:: [(Text, Text)] 
        }

deriving instance Show World

instance Default World where
 def    = World
        { worldArguments        = [] }


-------------------------------------------------------------------------------
-- | Control of state machine.
data Control
        = ControlExp !Exp
        | ControlPAP !PAP

deriving instance Show Control


-------------------------------------------------------------------------------
-- | Context of evaluation.
data Context
        = ContextNil

        -- | In an application we are evaluating the functional expression,
        --   and the frame holds the unevaluated argument.
        | ContextAppArg  !Value !Context

        -- | In an application we are evaluating the argument,
        --   and the frame holds the evaluated function.
        | ContextAppFun  !Value !Context

deriving instance Show Context


-------------------------------------------------------------------------------
pattern VVPAF p         = VPAP (PAF p [])

pattern VName n         = VVPAF (PVName     n)
pattern VList t xs      = VVPAF (PVList     t xs)
pattern VForest f       = VVPAF (PVForest   f)
pattern VTree t         = VVPAF (PVTree     t)
pattern VTreePath ts    = VVPAF (PVTreePath ts)
pattern VFilePath fp    = VVPAF (PVFilePath fp)

pattern VUnit           = VVPAF (PVAtom  AUnit)
pattern VBool    x      = VVPAF (PVAtom (ABool    x))
pattern VInt     x      = VVPAF (PVAtom (AInt     x))
pattern VFloat   x      = VVPAF (PVAtom (AFloat   x))
pattern VNat     x      = VVPAF (PVAtom (ANat     x))
pattern VDecimal x      = VVPAF (PVAtom (ADecimal x))
pattern VText    x      = VVPAF (PVAtom (AText    x))
pattern VTime    x      = VVPAF (PVAtom (ATime    x))
