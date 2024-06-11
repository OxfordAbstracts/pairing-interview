module Server.JWT where

import Prelude

import Data.Argonaut (class DecodeJson, class EncodeJson, Json, JsonDecodeError, decodeJson, encodeJson)
import Data.Either (Either)
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)

sign :: forall a m. MonadEffect m => EncodeJson a => a -> m String
sign = encodeJson >>> signImpl >>> liftEffect

foreign import signImpl :: Json -> Effect String

verify :: forall a m. MonadEffect m => DecodeJson a => String -> m (Either JsonDecodeError a)
verify = verifyImpl >>> map decodeJson >>> liftEffect

foreign import verifyImpl :: String -> Effect Json

foreign import secret :: String