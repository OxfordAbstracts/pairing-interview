module Web.Token where

import Prelude

import Data.Maybe (Maybe)
import Effect (Effect)
import Web.HTML (window)
import Web.HTML.Window (localStorage)
import Web.Storage.Storage (getItem, removeItem, setItem)

writeToken :: String -> Effect Unit
writeToken str =
  setItem tokenKey str =<< localStorage =<< window

removeToken :: Effect Unit
removeToken =
  removeItem tokenKey =<< localStorage =<< window

readToken :: Effect (Maybe String)
readToken = do
  getItem tokenKey =<< localStorage =<< window


tokenKey = "token" :: String
