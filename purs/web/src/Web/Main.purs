module Web.Main where

import Prelude

import Data.Maybe (Maybe(..))
import Debug (traceM)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Halogen (liftEffect)
import Halogen as H
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Routing.Duplex (parse)
import Routing.Hash (matchesWith)
import Web.API (getCurrentUser)
import Web.API as API
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
    Just _token -> do
      traceM { _token }
      getCurrentUser
  traceM { currentUser }
  let
    initialStore :: Store
    initialStore = { currentUser }
  rootComponent <- runAppM initialStore Router.component
  halogenIO <- runUI rootComponent unit body
  void $ liftEffect $ matchesWith (parse routeCodec) \old new -> do
    traceM { old, new, changed: old /= Just new }
    when (old /= Just new) $ launchAff_ do
      _response <- halogenIO.query $ H.mkTell $ Router.Navigate new
      pure unit