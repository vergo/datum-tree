
module Datum.Script.Core.Eval.Prim.Console
        (step_Console)
where
import Datum.Script.Core.Eval.Prim.Base
import Data.Default
import qualified System.IO                              as System
import qualified Datum.Data.Tree.Codec.Matryo.Encode    as Matryo
import qualified Data.Text.Lazy.IO                      as LText

step_Console _ _ PPPrint [VTree tree]
 = do   LText.hPutStr System.stdout (Matryo.prettyTree tree)
        progress $ VUnit

step_Console _ _ PPPrint [VVPAF (PVData d)]
 = do   LText.hPutStr System.stdout $ pprPrimData def d
        putStr "\n"
        progress $ VUnit

step_Console _ _ PPPrint [VVPAP PVUnit]
 = do   putStr "()\n"
        progress $ VUnit

step_Console _ _ _ _
 =      crash