module Server.Query where

import Prelude

import Effect.Aff (Aff)
import Server.DB as DB
import Yoga.Postgres (Query(..))
import Yoga.Postgres.SqlValue (toSql)

getAbstracts :: Aff (Array { title :: String, category :: String, first_name :: String, last_name :: String, email :: String })
getAbstracts = DB.query
  ( Query $
      """select title, category, first_name, last_name, email
  from abstracts
  inner join users on abstracts.user_id = users.id"""
  )
  []
