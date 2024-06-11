module Server.Query where

import Prelude

import Effect.Aff (Aff)
import Server.DB as DB
import Yoga.Postgres (Query(..))

getUsersWithEmail :: String -> Aff (Array { id :: String, email :: String, first_name :: String, last_name :: String, password :: String })
getUsersWithEmail email = DB.query
  ( Query $
      """
  SELECT id, email, first_name, last_name, password
  FROM users
  WHERE email = """ <> email
  )
  []
