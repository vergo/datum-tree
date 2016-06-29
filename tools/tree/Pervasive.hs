
module Pervasive where


strPervasive :: String
strPervasive
        = unlines
        [ -- Application, which implements the '$' operator.
          "apply  f x = f x;" 

          -- Reverse application, which implements the '&' operator.
        , "applyr x f = f x;" 
        ]

