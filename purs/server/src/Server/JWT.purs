module Server.JWT where

import Prelude

import Data.Argonaut (class EncodeJson, encodeJson, stringify)
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)

sign :: forall a m. MonadEffect m => EncodeJson a => a -> m String
sign = encodeJson >>> stringify >>> signImpl >>> liftEffect

foreign import signImpl :: String -> Effect String

foreign import secret :: String