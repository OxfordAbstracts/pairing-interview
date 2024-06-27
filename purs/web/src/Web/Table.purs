module Web.Table where

import Prelude

import Control.Monad.Error.Class (try)
import Data.Argonaut (Json, decodeJson, printJsonDecodeError)
import Data.Array (intercalate, reverse, sortWith, take)
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect.Aff.Class (class MonadAff, liftAff)
import Fetch (fetch)
import Foreign (Foreign)
import Halogen (liftAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Network.RemoteData (RemoteData(..))
import Unsafe.Coerce (unsafeCoerce)
import Web.HTML.Utils (css)

data SortCol = Id | Title | Category | SubmitterName | SubmitterEmail
data SortOrd = Asc | Desc
data SortConf = SortConf SortCol SortOrd

derive instance Eq SortCol
derive instance Eq SortOrd

data Action
  = Init
  | Receive Input
  | SortBy SortCol

type Input = {}

type State =
  { abstracts :: RemoteData String (Array Abstract), sortBy :: Maybe SortConf }

type Abstract =
  { title :: String
  , category :: String
  , first_name :: String
  , last_name :: String
  , email :: String
  }

component :: forall output m q. MonadAff m => H.Component q Input output m
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
  initialState = const { abstracts: NotAsked, sortBy: Nothing }

  render :: State -> HH.HTML _ Action
  render state =
    HH.div [ css "container mx-auto p-8" ]
      [ HH.table [ css "table-auto" ]
          [ HH.thead []
              [ HH.tr []
                  [ HH.th
                      [ css "px-4 py-2"
                      , HE.onClick $ const $ SortBy Id
                      ]
                      [ HH.text "Abstract ID" ]
                  , HH.th
                      [ css "px-4 py-2"
                      , HE.onClick $ const $ SortBy Title
                      ]
                      [ HH.text "Title" ]
                  , HH.th
                      [ css "px-4 py-2"
                      , HE.onClick $ const $ SortBy Category
                      ]
                      [ HH.text "Category" ]
                  ]
              , HH.th
                  [ css "px-4 py-2"
                  , HE.onClick $ const $ SortBy SubmitterName
                  ]
                  [ HH.text "Submitter Name" ]
              , HH.th
                  [ css "px-4 py-2"
                  , HE.onClick $ const $ SortBy SubmitterEmail
                  ]
                  [ HH.text "Submitter Email" ]
              ]
          ]
      , HH.tbody []
          case state.abstracts of
            NotAsked -> []
            Loading -> [ HH.text "Loading..." ]
            Failure err -> [ HH.text err ]
            Success abstracts ->
              let
                sortFunc = identity
              in
                abstracts # sortFunc # take 100 <#> \abstract ->
                  HH.tr []
                    [ HH.td [ css "border px-4 py-2" ] [ HH.text abstract.title ]
                    , HH.td [ css "border px-4 py-2" ] [ HH.text abstract.category ]
                    ]
      ]

  handleAction :: Action -> H.HalogenM State Action _ _ m Unit
  handleAction = case _ of
    Init -> do
      H.modify_ _ { abstracts = Loading }
      res <- liftAff $ fetch "http://localhost:8123/abstracts" {}
      json <- liftAff $ toJson <$> res.json
      H.modify_ _
        { abstracts = case decodeJson json of
            Left err -> Failure $ printJsonDecodeError err
            Right abstracts -> Success abstracts
        }

    Receive input ->
      pure unit

    SortBy sortCol -> pure unit

  toJson :: Foreign -> Json
  toJson = unsafeCoerce
