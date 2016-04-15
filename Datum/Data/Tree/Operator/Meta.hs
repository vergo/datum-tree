
module Datum.Data.Tree.Operator.Meta
        (HasFields (..))
where
import Datum.Data.Tree.Exp
import qualified Data.Repa.Array        as A


class HasFields a where
 -- | Rename the fields in a thing.
 -- 
 --   * If there are less new names than there are fields in the thing
 --     then the initial ones are renamed and the rest are preserved.
 --
 --   * If there are more new names then the excess ones are dropped.
 -- 
 renameFields :: [Name] -> a -> a


instance HasFields TupleType where
 renameFields ns' (TT nats)
  = let 
        (ns, ats) = unzip
                  $ [(n, at)    
                        | Box n :*: Box at <- A.toList nats]

        len       = length ns

        ns_init'  = take len ns'
        ns_tail   = drop (length ns_init') ns

        ns_new    = ns_init' ++ ns_tail

        nats'     = A.fromList
                  $ [Box n :*: Box at   
                        | n  <- ns_new
                        | at <- ats    ]
    in  TT nats'        


instance HasFields BranchType where
 renameFields ns' (BT n tt bts)
        = BT n (renameFields ns' tt) bts


instance HasFields (Tree c) where
 renameFields ns'  (Tree b bt)
        = Tree   b (renameFields ns' bt)


instance HasFields (Forest c) where
 renameFields ns'  (Forest g bt)
        = Forest g (renameFields ns' bt)


