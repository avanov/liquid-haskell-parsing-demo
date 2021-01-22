module Main where

import GHC.Generics (Generic)
import Data.Aeson (eitherDecode)
import Data.Aeson.Types (FromJSON)
import Text.RawString.QQ
import Data.ByteString (ByteString)
import Data.Either (isRight, partitionEithers)

-----------------------------------------------------------
-- Liquid Haskell imports
import Data.Text as T
import Data.Text.Unsafe as UT

-- Specs: http://ucsd-progsys.github.io/liquidhaskell/specifications/
{-@ measure txtLen :: Text -> Int @-}

{-@ assume T.pack :: i:String -> {o:T.Text | len i == txtLen o } @-}
-----------------------------------------------------------

jsonValid   = [r| { "locations": ["Europe", "US", "Asia"], "payload": "Important" } |]
jsonInvalid = [r| { "locations": ["Europe"], "payload": "Important" } |]


-- | Raw data that will firstly be parsed by Aeson and then predicate-parsed by LH helpers
data RawData = RawData
    { locations :: [String]
    , payload   :: String
    } deriving (Show, Eq, Ord, Generic, FromJSON)

-- Domain Data
{-@ type TextNE = {v:T.Text | 0 < txtLen v} @-}
{-@ type Destinations = {ls: [ v:TextNE ] | 2 <= len ls}  @-}
type Destinations = [T.Text]

-- | redundant replication of important data, at least 2 locations should be provided.
--   Note that it's safe to unpack 'Destinations' because LH verifies that the list
--   contains at least two items.
{-@ apiCallProvideRedundancy :: ls : Destinations -> d : TextNE -> (Bool, T.Text)  @-}
apiCallProvideRedundancy :: Destinations -> Text -> (Bool, T.Text)
apiCallProvideRedundancy (first: second: rest) dat =
    (True, "Data was persisted in at least '" <> first <> "' and '" <> second <> "' locations")


main :: IO ()
main = mapM_ (processAPI . eitherDecode) [jsonValid, jsonInvalid]


processAPI :: Either String RawData -> IO ()
processAPI json = do
    case json of
        Left invalid -> print invalid
        Right (RawData locs dat) ->
            case (parsedLocs, parsedData) of
                (Right (l : ll : lx), Right d) ->
                    print $ apiCallProvideRedundancy (l : ll : lx) d
                _ -> print "Input data has incorrect shape"
            where
                parsedLocs = case locs of
                    (x : xx: xs) -> Right . filterInvalid $ locs
                    _            -> Left "invalid destinations value"

                parsedData = case dat of
                    [] -> Left "Invalid"
                    _  -> Right . T.pack $ dat


{-@ filterInvalid :: xs:[String] -> rv:[TextNE]  @-}
filterInvalid :: [String] -> [Text]
filterInvalid = snd . partitionEithers . Prelude.map nonEmptyData

{-@ nonEmptyData :: x:String -> rv : (Either String {rght:TextNE | txtLen rght == len x})   @-}
nonEmptyData :: String -> Either String Text
nonEmptyData x = case x of
    [] -> Left x
    _  -> Right $ T.pack x
