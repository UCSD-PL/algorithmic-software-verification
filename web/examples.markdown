---
title: Examples 
---

~~~~~{.haskell}
fac :: Integer -> Integer
fac 0 = 1
fac n = n * fac (n-1)
~~~~~

~~~~~{.haskell}
import Text.Hakyll (hakyll)
import Control.Monad.Trans (liftIO)
main = hakyll "http://example.com" $ do
    liftIO $ putStrLn "I'm in your computer, generating your site!"
~~~~~

