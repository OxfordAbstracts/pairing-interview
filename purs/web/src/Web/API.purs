module Web.API where

import Prelude

import Control.Monad.Error.Class (liftEither)
import Data.Argonaut (class DecodeJson, Json, decodeJson, printJsonDecodeError)
import Data.Bifunctor (lmap)
import Effect.Aff (error, throwError)
import Effect.Aff.Class (class MonadAff, liftAff)
import Fetch (Method(..), fetch)
import Foreign (Foreign)
import Unsafe.Coerce (unsafeCoerce)

get :: forall m res. MonadAff m => DecodeJson res => String -> m res
get path = liftAff do
  { json, ok, statusText } <- fetch ("http://localhost:8123/" <> path)
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

