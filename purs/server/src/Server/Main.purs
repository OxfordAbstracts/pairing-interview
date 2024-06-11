module Server.Main (main) where

import Prelude hiding ((/))

import Control.Monad.Cont (ContT, lift)
import Data.Argonaut (class DecodeJson, class EncodeJson, decodeJson, encodeJson, parseJson, stringify)
import Data.Array (head)
import Data.DateTime.Instant (unInstant)
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Now as Date
import HTTPurple (class Generic, JsonDecoder(..), Method(..), Response, RouteDuplex', ServerM, fromJson, jsonHeaders, mkRoute, noArgs, notFound, ok', serve, unauthorized, usingCont, (/))
import HTTPurple as HTTPure
import HTTPurple.Body (RequestBody)
import Node.Process as Process
import Server.JWT (sign)
import Server.Query (getUsersWithEmail)

data Route
  = Healthcheck
  | SignIn

derive instance Generic Route _

route :: RouteDuplex' Route
route = mkRoute
  { "Healthcheck": "healthcheck" / noArgs
  , "SignIn": "sign-in" / noArgs
  }

main :: ServerM
main =
  serve { port: 8123 } { route, router }
  where
  router = case _ of
    { route: Healthcheck } -> do
      uptime <- liftEffect Process.uptime
      timestamp <- getTimestamp
      jsonOk { uptime, timestamp, message: "ok" }

    { route: SignIn, method: Post, body } -> usingCont do
      { password, email } :: { password :: String, email :: String } <- decodeBody body
      users <- lift $ getUsersWithEmail email

      case head users of
        Just user@{ id } | password == user.password -> do
          let creds = 
               { email
               , id 
               , "X-Hasura-User-Id": show id
               }
          token <- sign creds
          let
            headers = HTTPure.headers
              { "Content-Type": "application/json"
              , "Set-Cookie": "token=" <> token
              }
          ok' headers $ toJson creds
        _ -> unauthorized

    _ -> notFound

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
