module Server.Main (main) where

import Prelude hiding ((/))

import Control.Monad.Cont (ContT, lift)
import Data.Argonaut (class DecodeJson, class EncodeJson, decodeJson, encodeJson, parseJson, stringify)
import Data.Array (head)
import Data.DateTime.Instant (unInstant)
import Data.Either (hush)
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.String (Pattern(..), joinWith, stripPrefix)
import Data.Tuple.Nested ((/\))
import Debug (spy, traceM)
import Effect.Aff (Aff, try)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Now as Date
import HTTPurple (class Generic, JsonDecoder(..), Method(..), Middleware, RequestR, Response, RouteDuplex', ServerM, fromJson, jsonHeaders, lookup, mkRoute, noArgs, notFound, ok, ok', serve, unauthorized, usingCont, (/))
import HTTPurple as HTTPure
import HTTPurple.Body (RequestBody)
import Node.Process as Process
import Prim.Row (class Nub, class Union)
import Record (merge)
import Server.JWT (sign, verify)
import Server.Query (getUsersWithEmail)

data Route
  = Healthcheck
  | SignIn
  | CurrentUser

derive instance Generic Route _

route :: RouteDuplex' Route
route = mkRoute
  { "Healthcheck": "healthcheck" / noArgs
  , "SignIn": "sign-in" / noArgs
  , "CurrentUser": "current-user" / noArgs
  }

main :: ServerM
main =
  serve { port: 8123 } { route, router: authenticator router >>> map addCorsHeaders }
  where
  router = case _ of
    { method: Options } -> do
      ok' corsHeaders ""
    { route: Healthcheck } -> do
      uptime <- liftEffect Process.uptime
      timestamp <- getTimestamp
      jsonOk { uptime, timestamp, message: "ok" }

    { route: SignIn, method: Post, body } -> usingCont do
      { password, email } :: { password :: String, email :: String } <- decodeBody body
      users <- lift $ getUsersWithEmail email
      case head users of
        Just foundUser@{ id, first_name, last_name } | password == foundUser.password -> do
          let
            user =
              { email
              , id
              , first_name
              , last_name
              , "X-Hasura-User-Id": show id
              }
          token <- sign user
          let
            headers = HTTPure.headers
              { "Content-Type": "application/json"
              , "Set-Cookie": "token=" <> token
              }
          ok' headers $ toJson { token, user }
        _ -> unauthorized

    { route: CurrentUser, method: Get, user } -> usingCont do
      ok $ stringify $ encodeJson user

    req -> do
      log $ "not found: " <> joinWith "/" req.path
      notFound

  addCorsHeaders res@{ headers } =
    res { headers = headers <> corsHeaders }

  corsHeaders =
    HTTPure.headers
      [ "Access-Control-Allow-Origin" /\ "http://localhost:3000"
      , "Access-Control-Allow-Credentials" /\ "true"
      , "Access-Control-Allow-Methods" /\ "GET,POST,OPTIONS"
      , "Access-Control-Allow-Headers" /\ "Content-Type,Authorization"
      ]

authenticator
  :: forall route extIn extOut
   . Nub (RequestR route extOut) (RequestR route extOut)
  => Union extIn (user :: Maybe User) extOut
  => Middleware route extIn extOut
authenticator router request@{ headers } =
  case lookup headers "Authorization" >>= stripPrefix (Pattern "Bearer ") of
    Just token -> do
      verified :: _ (_ _ User) <- try $ verify token
      traceM { verified }
      router $ merge request { user: hush =<< hush verified }
    _ -> router $ merge request { user: Nothing :: Maybe User }

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
