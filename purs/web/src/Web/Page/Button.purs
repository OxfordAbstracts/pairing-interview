module Web.Page.Button where

import Prelude

import Control.Monad.Error.Class (try)
import Data.Argonaut (Json)
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Debug (traceM)
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff)
import Effect.Class.Console (logShow)
import Halogen (lift)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Web.API as API
import Web.Hasura as Hasura

type State = { enabled :: Boolean }

data Action = Toggle | Init

component :: forall q i o. H.Component q i o Aff
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval $ H.defaultEval
        { handleAction = handleAction
        , initialize = Just Init
        }
    }

initialState :: forall i. i -> State
initialState _ = { enabled: false }

render :: forall m. State -> H.ComponentHTML Action () m
render state =
  let
    label = if state.enabled then "On" else "Off"
  in
    HH.button
      [ HP.title label
      , HE.onClick \_ -> Toggle
      ]
      [ HH.text label ]

handleAction :: forall o. Action -> H.HalogenM State Action () o Aff Unit
handleAction = case _ of
  Init -> do
    -- res :: _ _ { users :: Array {} } <- lift $ try $ Hasura.query' """
    --   query { users { id } }
    -- """

    res :: Json <- API.get "healthcheck"
    traceM res
    pure unit
  Toggle ->
    H.modify_ \st -> st { enabled = not st.enabled }