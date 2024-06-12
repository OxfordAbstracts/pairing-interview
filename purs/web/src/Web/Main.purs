module Web.Main where

import Prelude

import Effect (Effect)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Web.Table as Table

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  void $ runUI Table.component {} body
