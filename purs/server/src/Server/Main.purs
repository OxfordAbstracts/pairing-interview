module Server.Main (main) where

import Prelude hiding ((/))

import Control.Monad.Cont (ContT)
import Data.Argonaut (class DecodeJson, class EncodeJson, decodeJson, encodeJson, parseJson, stringify)
import Data.DateTime.Instant (unInstant)
import Data.Newtype (unwrap)
import Data.Tuple.Nested ((/\))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Now as Date
import HTTPurple (class Generic, JsonDecoder(..), Method(..), Response, RouteDuplex', ServerM, fromJson, jsonHeaders, mkRoute, noArgs, ok', serve, (/))
import HTTPurple as HTTPure
import HTTPurple.Body (RequestBody)
import Node.Process as Process
import Server.Query (getAbstracts)

data Route
  = Healthcheck
  | Abstracts

derive instance Generic Route _

route :: RouteDuplex' Route
route = mkRoute
  { "Healthcheck": "healthcheck" / noArgs
  , "Abstracts": "abstracts" / noArgs
  }

main :: ServerM
main =
  serve { port: 8123 } { route, router: router >>> map addCorsHeaders }
  where
  router = case _ of
    { method: Options } -> do
      ok' corsHeaders ""
    { route: Healthcheck } -> do
      uptime <- liftEffect Process.uptime
      timestamp <- getTimestamp
      jsonOk { uptime, timestamp, message: "ok" }

    { route: Abstracts } -> do
      abstracts <- getAbstracts
      jsonOk abstracts
  addCorsHeaders res@{ headers } =
    res { headers = headers <> corsHeaders }

  corsHeaders =
    HTTPure.headers
      [ "Access-Control-Allow-Origin" /\ "http://localhost:3000"
      , "Access-Control-Allow-Credentials" /\ "true"
      , "Access-Control-Allow-Methods" /\ "GET,POST,OPTIONS"
      , "Access-Control-Allow-Headers" /\ "Content-Type,Authorization"
      ]

type User = { email :: String, id :: String, first_name :: String, last_name :: String }

jsonOk :: forall a. EncodeJson a => a -> Aff Response
jsonOk = ok' jsonHeaders <<< toJson

toJson :: forall a. EncodeJson a => a -> String
toJson = stringify <<< encodeJson

getTimestamp :: Aff Number
getTimestamp = liftEffect $ unwrap <<< unInstant <$> Date.now

decodeBody
  :: forall a
   . DecodeJson a
  => RequestBody
  -> ContT Response Aff a
decodeBody = fromJson (JsonDecoder $ decodeJson <=< parseJson)
