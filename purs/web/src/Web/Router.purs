module Web.Router where

import Prelude
-- import Conduit.Capability.LogMessages (class LogMessages)
-- import Conduit.Capability.Navigate (class Navigate, navigate)
-- import Conduit.Capability.Now (class Now)
-- import Conduit.Capability.Resource.Article (class ManageArticle)
-- import Conduit.Capability.Resource.Comment (class ManageComment)
-- import Conduit.Capability.Resource.Tag (class ManageTag)
-- import Conduit.Capability.Resource.User (class ManageUser)
-- import Conduit.Component.Utils (OpaqueSlot)
-- import Conduit.Data.Profile (Profile)
-- import Conduit.Data.Route (Route(..), routeCodec)
-- import Conduit.Page.Editor as Editor
-- import Conduit.Page.Home as Home
-- import Conduit.Page.Login as Login
-- import Conduit.Page.Profile (Tab(..))
-- import Conduit.Page.Profile as Profile
-- import Conduit.Page.Register as Register
-- import Conduit.Page.Settings as Settings
-- import Conduit.Page.ViewArticle as ViewArticle
import Web.Store as Store
import Data.Either (hush)
import Data.Foldable (elem)
import Data.Maybe (Maybe(..), fromMaybe, isJust)
import Effect.Aff.Class (class MonadAff)
import Halogen (liftEffect)
import Halogen as H
import Halogen.HTML as HH
import Halogen.Store.Connect (Connected, connect)
import Halogen.Store.Monad (class MonadStore)
import Halogen.Store.Select (selectEq)
import Routing.Duplex as RD
import Routing.Hash (getHash)
import Type.Proxy (Proxy(..))


