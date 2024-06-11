module Web.Hasura
  ( query
  , query'
  ) where

import Prelude

import Control.Monad.Error.Class (liftEither)
import Data.Argonaut (class DecodeJson, class EncodeJson, Json, decodeJson, encodeJson, printJsonDecodeError, stringify)
import Data.Bifunctor (lmap)
import Effect.Aff (Aff, error, throwError)
import Effect.Aff.Class (class MonadAff, liftAff)
import Fetch (Method(..), fetch)
import Foreign (Foreign)
import Foreign.Object (Object)
import Unsafe.Coerce (unsafeCoerce)

query :: forall a m. MonadAff m => DecodeJson a => String -> Object Json -> m a
query q variables = makeGqlRequest
  { query: q
  , variables
  }

query' :: forall a m. MonadAff m => DecodeJson a => String -> m a
query' q = makeGqlRequest
  { query: q
  }

makeGqlRequest :: forall res body m. MonadAff m => EncodeJson body => DecodeJson res => body -> m res
makeGqlRequest body = liftAff do
  { json, ok, statusText } <- fetch "http://localhost:9695/"
    { method: POST
    , body: stringify $ encodeJson body
    , headers: { "Content-Type": "application/json" }
    }
  if not ok then
    throwError $ error $ "Failed to fetch: " <> statusText
  else do
    jsonRes <- toJson <$> json
    liftEither $ lmap (error <<< printJsonDecodeError) $ decodeJson jsonRes
  where
  toJson :: Foreign -> Json
  toJson = unsafeCoerce

