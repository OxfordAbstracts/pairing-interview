module Web.API where

import Prelude

import Control.Monad.Error.Class (liftEither)
import Data.Argonaut (class DecodeJson, class EncodeJson, Json, decodeJson, encodeJson, printJsonDecodeError, stringify)
import Data.Bifunctor (lmap)
import Effect.Aff (error, throwError)
import Effect.Aff.Class (class MonadAff, liftAff)
import Fetch (Method(..), fetch)
import Foreign (Foreign)
import Unsafe.Coerce (unsafeCoerce)


get :: forall m res. MonadAff m => DecodeJson res => String -> m res
get path = liftAff do
  { json, ok, statusText } <- fetch (apiUrl <> path)
    { method: GET
    }
  if not ok then
    throwError $ error $ "Failed to fetch: " <> statusText
  else do
    jsonRes <- toJson <$> json
    liftEither $ lmap (error <<< printJsonDecodeError) $ decodeJson jsonRes
  where
  toJson :: Foreign -> Json
  toJson = unsafeCoerce

post :: forall m body res. MonadAff m => EncodeJson body => DecodeJson res => String -> body -> m res
post path body = liftAff do
  { json, ok, statusText } <- fetch (apiUrl <> path)
    { method: POST
    , body: stringify $ encodeJson body
    }
  if not ok then
    throwError $ error $ "Failed to fetch: " <> statusText
  else do
    jsonRes <- toJson <$> json
    liftEither $ lmap (error <<< printJsonDecodeError) $ decodeJson jsonRes
  where
  toJson :: Foreign -> Json
  toJson = unsafeCoerce

apiUrl :: String
apiUrl = "http://localhost:8123/"