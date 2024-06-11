module Web.Page.SignIn where

import Prelude

import Control.Monad.Error.Class (class MonadError, try)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Debug (traceM)
import Effect.Aff.Class (class MonadAff)
import Effect.Class.Console (errorShow)
import Effect.Exception (Error)
import Formless as F
import Halogen (lift, liftEffect)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Store.Monad (class MonadStore, updateStore)
import Web.API as API
import Web.Capability.Navigate (class Navigate, navigate)
import Web.Form.Field as Field
import Web.Form.Validation (FormError)
import Web.Form.Validation as V
import Web.HTML.Utils (css, whenElem)
import Web.Route (Route(..))
import Web.Store (Profile)
import Web.Store as Store
import Web.Token (writeToken)

type Input = { redirect :: Boolean }

type Form :: (Type -> Type -> Type -> Type) -> Row Type
type Form f =
  ( email :: f String FormError String
  , password :: f String FormError String
  )

type FormContext = F.FormContext (Form F.FieldState) (Form (F.FieldAction Action)) Input Action
type FormlessAction = F.FormlessAction (Form F.FieldState)

data Action
  = Receive FormContext
  | Eval FormlessAction

type State =
  { form :: FormContext
  , loginError :: Boolean
  }

component
  :: forall query output m
   . MonadAff m
  => MonadError Error m
  => MonadStore Store.Action Store.Store m
  => Navigate m
  -- => ManageUser m
  => H.Component query Input output m
component = F.formless { liftAction: Eval } mempty $ H.mkComponent
  { initialState: \context -> { form: context, loginError: false }
  , render
  , eval: H.mkEval $ H.defaultEval
      { receive = Just <<< Receive
      , handleAction = handleAction
      , handleQuery = handleQuery
      }
  }
  where
  handleAction :: Action -> H.HalogenM _ _ _ _ _ Unit
  handleAction = case _ of
    Receive context -> H.modify_ _ { form = context }
    Eval action -> F.eval action

  handleQuery :: forall a. F.FormQuery _ _ _ _ a -> H.HalogenM _ _ _ _ _ (Maybe a)
  handleQuery = do
    let
      -- onSubmit also handles broadcasting the user changes to subscribed components
      -- so they receive the up-to-date value (see AppM and the `authenticate` function.)
      onSubmit = signInUser >=> case _ of
        Nothing ->
          H.modify_ _ { loginError = true }
        Just signedIn -> do
          traceM { signedIn }
          -- updateStore $ Store.LoginUser signedIn
          H.modify_ _ { loginError = false }
          { redirect } <- H.gets _.form.input
          when redirect (navigate Home)

      validation =
        { email: V.required >=> V.minLength 3
        , password: V.required >=> V.minLength 2 >=> V.maxLength 20
        }

    F.handleSubmitValidate onSubmit F.validate validation

  render :: State -> H.ComponentHTML Action () m
  render { loginError, form: { formActions, fields, actions } } =
    container
      [ HH.h1
          [ css "text-xs-center" ]
          [ HH.text "Sign In" ]

      , HH.form
          [ HE.onSubmit formActions.handleSubmit ]
          [ whenElem loginError \_ ->
              HH.div
                [ css "error-messages" ]
                [ HH.text "Email or password is invalid" ]
          , HH.fieldset_
              [ Field.textInput
                  { state: fields.email, action: actions.email }
                  [ HP.placeholder "Email"
                  , HP.type_ HP.InputEmail
                  ]
              , Field.textInput
                  { state: fields.password, action: actions.password }
                  [ HP.placeholder "Password"
                  , HP.type_ HP.InputPassword
                  ]
              , Field.submitButton "Log in"
              ]
          ]
      ]
    where
    container html =
      HH.div
        [ css "auth-page" ]
        [ HH.div
            [ css "container page" ]
            [ HH.div
                [ css "row" ]
                [ HH.div
                    [ css "col-md-6 offset-md-3 col-xs12" ]
                    html
                ]
            ]
        ]

  signInUser input = do
    apiRes :: _ _ { user :: Profile, token :: String } <- lift $ try $ API.post "sign-in" input
    case apiRes of
      Left err -> do
        errorShow err
        pure Nothing
      Right res -> do
        liftEffect $ writeToken res.token
        updateStore $ Store.LoginUser res.user
        pure $ Just res.user