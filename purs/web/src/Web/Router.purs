module Web.Router where

import Prelude

import Control.Monad.Error.Class (class MonadError)
import Data.Either (hush)
import Data.Foldable (elem)
import Data.Maybe (Maybe(..), fromMaybe, isJust)
import Effect.Aff.Class (class MonadAff)
import Effect.Exception (Error)
import Halogen (liftEffect)
import Halogen as H
import Halogen.HTML as HH
import Halogen.Store.Connect (Connected, connect)
import Halogen.Store.Monad (class MonadStore)
import Halogen.Store.Select (selectEq)
import Routing.Duplex as RD
import Routing.Hash (getHash)
import Type.Proxy (Proxy(..))
import Web.Capability.Navigate (class Navigate, navigate)
import Web.Page.SignIn as SignIn
import Web.Route (Route(..), routeCodec)
import Web.Store (Profile)
import Web.Store as Store

data Query a = Navigate Route a

type State =
  { route :: Maybe Route
  , currentUser :: Maybe Profile
  }

data Action
  = Initialize
  | Receive (Connected (Maybe Profile) Unit)

component
  :: forall m
   . MonadAff m
  => MonadStore Store.Action Store.Store m
  => Navigate m
  => MonadError Error m
  => H.Component Query Unit Void m
component = connect (selectEq _.currentUser) $ H.mkComponent
  { initialState: \{ context: currentUser } -> { route: Nothing, currentUser }
  , render
  , eval: H.mkEval $ H.defaultEval
      { handleQuery = handleQuery
      , handleAction = handleAction
      , receive = Just <<< Receive
      , initialize = Just Initialize
      }
  }
  where
  handleAction :: Action -> H.HalogenM State Action _ Void m Unit
  handleAction = case _ of
    Initialize -> do
      -- first we'll get the route the user landed on
      initialRoute <- hush <<< (RD.parse routeCodec) <$> liftEffect getHash
      -- then we'll navigate to the new route (also setting the hash)
      navigate $ fromMaybe Home initialRoute

    Receive { context: currentUser } ->
      H.modify_ _ { currentUser = currentUser }

  handleQuery :: forall a. Query a -> H.HalogenM State Action _ Void m (Maybe a)
  handleQuery = case _ of
    Navigate dest a -> do
      { route, currentUser } <- H.get
      -- don't re-render unnecessarily if the route is unchanged
      when (route /= Just dest) do
        -- don't change routes if there is a logged-in user trying to access
        -- a route only meant to be accessible to a not-logged-in session
        case (isJust currentUser && dest `elem` [ SignIn ]) of
          false -> H.modify_ _ { route = Just dest }
          _ -> pure unit
      pure (Just a)

  -- Display the SignIn page instead of the expected page if there is no current user; a simple
  -- way to restrict access.
  authorize :: Maybe Profile -> H.ComponentHTML Action _ m -> H.ComponentHTML Action _ m
  authorize mbProfile html = case mbProfile of
    Nothing ->
      HH.slot (Proxy :: _ "SignIn") unit SignIn.component { redirect: false } absurd
    Just _ ->
      html

  render :: State -> H.ComponentHTML Action _ m
  render { route, currentUser } = case currentUser of
    Nothing -> HH.slot (Proxy :: _ "SignIn") unit SignIn.component { redirect: false } absurd
    _ -> HH.div_ [ HH.text "Oh no! That page wasn't found." ]
--  case route of
-- -- Just r -> case r of
-- -- Home ->
-- --   HH.slot_ (Proxy :: _ "home") unit Home.component unit
-- -- SignIn ->
-- --   HH.slot_ (Proxy :: _ "SignIn") unit SignIn.component { redirect: true }
-- -- Register ->
-- --   HH.slot_ (Proxy :: _ "register") unit Register.component unit
-- -- Settings -> authorize currentUser do
-- --   HH.slot_ (Proxy :: _ "settings") unit Settings.component unit
-- -- Editor -> authorize currentUser do
-- --   HH.slot_ (Proxy :: _ "editor") unit Editor.component Nothing
-- -- EditArticle slug -> authorize currentUser do
-- --   HH.slot_ (Proxy :: _ "editor") unit Editor.component (Just slug)
-- -- ViewArticle slug ->
-- --   HH.slot_ (Proxy :: _ "viewArticle") unit ViewArticle.component slug
-- -- Profile username ->
-- --   HH.slot_ (Proxy :: _ "profile") unit Profile.component { username, tab: ArticlesTab }
-- -- Favorites username ->
-- --   HH.slot_ (Proxy :: _ "profile") unit Profile.component { username, tab: FavoritesTab }
-- _ ->
--   HH.slot_ ()