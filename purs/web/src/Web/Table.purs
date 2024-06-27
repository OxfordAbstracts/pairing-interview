module Web.Table where

import Prelude

import Control.Monad.Error.Class (class MonadError, catchError, try)
import Data.Argonaut (Json, decodeJson, printJsonDecodeError)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Exception (Error)
import Fetch (fetch)
import Foreign (Foreign)
import Halogen (liftAff)
import Halogen as H
import Halogen.HTML as HH
import Network.RemoteData (RemoteData(..))
import Unsafe.Coerce (unsafeCoerce)
import Web.HTML.Utils (css)

data Action
  = Init
  | Receive Input

type Input = {}

type State =
  { abstracts :: RemoteData String (Array Abstract) }

type Abstract =
  { title :: String
  , category :: String
  , first_name :: String
  , last_name :: String
  , email :: String
  }

component :: forall output m q. MonadError Error m => MonadAff m => H.Component q Input output m
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval H.defaultEval
        { handleAction = handleAction
        , initialize = Just Init
        }
    }
  where
  initialState :: Input -> State
  initialState = const { abstracts: NotAsked }

  render :: State -> HH.HTML _ Action
  render state =
    HH.div [ css "container mx-auto p-8" ]
      [ HH.table [ css "table-auto" ]
          [ HH.thead []
              [ HH.tr []
                  [ HH.th
                      [ css "px-4 py-2"
                      ]
                      [ HH.text "Title" ]
                  , HH.th
                      [ css "px-4 py-2"
                      ]
                      [ HH.text "Category" ]
                  ]

              ]
          ]
      , HH.tbody []
          case state.abstracts of
            NotAsked -> []
            Loading -> [ HH.text "Loading..." ]
            Failure err -> [ HH.text err ]
            Success abstracts ->
              abstracts <#> \abstract ->
                HH.tr []
                  [ HH.td [ css "border px-4 py-2" ] [ HH.text abstract.title ]
                  , HH.td [ css "border px-4 py-2" ] [ HH.text abstract.category ]
                  ]
      ]

  handleAction :: Action -> H.HalogenM State Action _ _ m Unit
  handleAction = case _ of
    Init -> do
      H.modify_ _ { abstracts = Loading }
      let
        callApi = do
          res <- fetch "http://localhost:8123/abstracts" {}
          toJson <$> res.json

      res <- liftAff $ try callApi

      case res of
        Left err -> do
          H.modify_ _ { abstracts = Failure $ show err }

        Right json ->
          H.modify_ _
            { abstracts = case decodeJson json of
                Left err -> Failure $ printJsonDecodeError err
                Right abstracts -> Success abstracts
            }

    Receive input ->
      pure unit

  toJson :: Foreign -> Json
  toJson = unsafeCoerce
