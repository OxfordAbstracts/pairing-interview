module Web.Store where


import Data.Maybe (Maybe(..))



type Store =
  { currentUser :: Maybe Profile
  }

type Profile =
  { id :: String
  , email :: String
  , first_name :: String
  , last_name :: String
  }

data Action
  = LoginUser Profile
  | LogoutUser

reduce :: Store -> Action -> Store
reduce store = case _ of
  LoginUser profile ->
    store { currentUser = Just profile }

  LogoutUser ->
    store { currentUser = Nothing }

