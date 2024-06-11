module Web.Main where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Halogen (liftEffect)
import Halogen as H
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Routing.Duplex (parse)
import Routing.Hash (matchesWith)
import Web.AppM (runAppM)
import Web.Route (routeCodec)
import Web.Router as Router
import Web.Store (Store, Profile)
import Web.Token (readToken)

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody

  currentUser :: Maybe Profile <- (liftEffect readToken) >>= case _ of
    Nothing ->
      pure Nothing

    Just token -> pure Nothing
  -- do
  --   let requestOptions = { endpoint: User, method: Get }
  --   res <- request $ defaultRequest baseUrl (Just token) requestOptions

  --   let
  --     user :: Either String Profile
  --     user = case res of
  --       Left e ->
  --         Left (printError e)
  --       Right v -> lmap printJsonDecodeError do
  --         u <- Codec.decode (CAR.object "User" { user: CA.json }) v.body
  --         CA.decode Profile.profileCodec u.user

  --   pure $ hush user
  let
    initialStore :: Store
    initialStore = { currentUser }
  rootComponent <- runAppM initialStore Router.component
  halogenIO <- runUI rootComponent unit body
  void $ liftEffect $ matchesWith (parse routeCodec) \old new ->
    when (old /= Just new) $ launchAff_ do
      _response <- halogenIO.query $ H.mkTell $ Router.Navigate new
      pure unit