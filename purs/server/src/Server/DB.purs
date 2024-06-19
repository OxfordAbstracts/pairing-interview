module Server.DB
  ( mkPool
  , query
  ) where

import Prelude

import Data.Argonaut (class DecodeJson, Json, decodeJson, printJsonDecodeError)
import Data.Bifunctor (lmap)
import Data.Either (Either)
import Effect (Effect)
import Effect.Aff (Aff, Error, error)
import Effect.Class (liftEffect)
import Foreign (Foreign, unsafeFromForeign)
import Yoga.Postgres (Pool, Query, connectionInfoFromString, withClient)
import Yoga.Postgres as Postgres
import Yoga.Postgres.SqlValue (SqlValue)

mkPool :: Effect Pool
mkPool = Postgres.mkPool (connectionInfoFromString "postgres://postgres:postgrespassword@localhost:5432/postgres")

query
  :: forall a
   . DecodeJson a
  => Query a
  -> Array SqlValue
  -> Aff (Array a)
query q values = do
  pool <- liftEffect mkPool
  withClient pool \client ->
    Postgres.query decodeDb q values client

decodeDb :: forall a. DecodeJson a => Foreign -> Either Error a
decodeDb = (unsafeFromForeign :: _ -> Json) >>> decodeJson >>> lmap (printJsonDecodeError >>> error)

