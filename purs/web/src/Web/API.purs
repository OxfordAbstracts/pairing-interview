module Web.API where

import Prelude

import Control.Monad.Error.Class (liftEither)
import Data.Argonaut (class DecodeJson, class EncodeJson, Json, decodeJson, encodeJson, printJsonDecodeError, stringify)
import Data.Bifunctor (lmap)
import Data.Foldable (fold)
import Data.Maybe (Maybe)
import Effect.Aff (error, throwError)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (liftEffect)
import Fetch (Method(..), fetch)
import Foreign (Foreign)
import Unsafe.Coerce (unsafeCoerce)
import Web.Store (Profile)
import Web.Token (readToken)

getCurrentUser :: forall m. MonadAff m => m (Maybe Profile)
getCurrentUser = get "current-user"

get :: forall m res. MonadAff m => DecodeJson res => String -> m res
get path = liftAff do
  token <- liftEffect readToken
  { json, ok, statusText } <- fetch (apiUrl <> path)
    { method: GET
    , headers: { "Authorization": "Bearer " <> fold token }
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
  token <- liftEffect readToken
  { json, ok, statusText } <- fetch (apiUrl <> path)
    { method: POST
    , body: stringify $ encodeJson body
    , headers: { "Authorization": "Bearer " <> fold token }
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