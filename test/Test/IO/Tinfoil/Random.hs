{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell   #-}

module Test.IO.Tinfoil.Random where

import           Data.Char (ord)
import           Data.List (intersect)
import           Data.List.NonEmpty (NonEmpty)
import qualified Data.List.NonEmpty as NE
import           Data.Maybe (fromJust)
import qualified Data.Text                     as T

import           Disorder.Core.IO

import           P

import           System.IO

import           Tinfoil.Data
import           Tinfoil.Random

import           Test.QuickCheck
import           Test.Tinfoil.Arbitrary

prop_randomCredential_length :: Property
prop_randomCredential_length = forAll ((,) <$> credentialLength <*> excludedChars) $ \(l, ex) -> testIO $ do
  c <- randomCredential ex l
  pure $ (T.length . unCredential $ fromJust c) === l

prop_randomCredential_exclusion :: Property
prop_randomCredential_exclusion = forAll ((,) <$> credentialLength <*> excludedChars) $ \(l, ex) -> testIO $ do
  c <- randomCredential ex l
  pure $ (intersect (T.unpack . unCredential $ fromJust c) ex) === []

prop_randomCredential_empty :: Property
prop_randomCredential_empty = forAll credentialLength $ \l -> testIO $ do
  c <- randomCredential (NE.toList credentialCharSet) l
  pure $ c == Nothing

prop_randomCredential_printable :: Property
prop_randomCredential_printable = forAll credentialLength $ \l -> testIO $ do
  cr <- randomCredential [] l
  pure $ all (\c -> ord c < 128 && ord c >= 32) (T.unpack . unCredential $ fromJust cr)

prop_drawOnce_closure :: Property
prop_drawOnce_closure = forAll arbitrary $ \(xs :: NonEmpty Int) -> testIO $ do
  x <- drawOnce xs
  pure $ elem x xs

return []
tests :: IO Bool
tests = $forAllProperties $ quickCheckWithResult (stdArgs { maxSuccess = 100 } )