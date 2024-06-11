module Web.Route where

import Prelude

import Prelude hiding ((/))

import Data.Either (note)
import Data.Generic.Rep (class Generic)
import Routing.Duplex (RouteDuplex', as, root, segment)
import Routing.Duplex.Generic (noArgs, sum)
import Routing.Duplex.Generic.Syntax ((/))

-- | We'll represent routes in our application with a simple sum type. As the application grows,
-- | you might want to swap this out with an extensible sum type with `Variant` and have several
-- | sub-sections. For our small MVP this type will work just fine and will prevent us from trying
-- | to send users to non-existent routes.
data Route
  = Home
  | SignIn

derive instance genericRoute :: Generic Route _
derive instance eqRoute :: Eq Route
derive instance ordRoute :: Ord Route

-- | Next, we'll define a bidirectional codec for our route parsing. Our single codec will handle
-- | both parsing browser locations and serializing our data type to a browser location. We'll skip
-- | the boilerplate of separate encoding and decoding functions, and we'll ensure our parsing and
-- | printing is always in sync.
-- |
-- | Our codec will cause a compile-time error if we fail to handle any of our route cases.
routeCodec :: RouteDuplex' Route
routeCodec = root $ sum
  { "Home": noArgs
  , "SignIn": "sign-in" / noArgs
  }

