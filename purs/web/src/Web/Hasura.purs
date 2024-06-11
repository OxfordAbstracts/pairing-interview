module Web.Hasura
  ( query
  ) where

import Prelude

import Control.Monad.Error.Class (liftEither)
import Data.Argonaut (class DecodeJson, class EncodeJson, Json, decodeJson, encodeJson, printJsonDecodeError, stringify)
import Data.Bifunctor (lmap)
import Effect.Aff (Aff, error, throwError)
import Fetch (Method(..), fetch)
import Foreign (Foreign)
import Foreign.Object (Object)
import Unsafe.Coerce (unsafeCoerce)

query :: forall a. DecodeJson a => String -> Object Json -> Aff a
query q variables = makeGqlRequest
  { query: q
  , variables
  }

makeGqlRequest :: forall res body. EncodeJson body => DecodeJson res => body -> Aff res
makeGqlRequest body = do
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

