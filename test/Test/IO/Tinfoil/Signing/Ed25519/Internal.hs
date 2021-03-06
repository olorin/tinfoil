{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE GADTs #-}
module Test.IO.Tinfoil.Signing.Ed25519.Internal where

import           Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import qualified Data.Text as T

import           Disorder.Core.IO (testIO)
import           Disorder.Core.Property (failWith)

import           P

import           System.IO

import           Test.QuickCheck
import           Test.QuickCheck.Instances ()

import           Tinfoil.Data
import           Tinfoil.Signing.Ed25519.Internal

prop_genKeyPair_len :: Property
prop_genKeyPair_len = testIO $ do
  (PKey_Ed25519 pk, SKey_Ed25519 sk) <- genKeyPair
  pure $ (BS.length pk, BS.length sk) === (pubKeyLen, secKeyLen)

prop_genKeyPair :: Property
prop_genKeyPair = testIO $ do
  (pk1, sk1) <- genKeyPair
  (pk2, sk2) <- genKeyPair
  pure $ (pk1 == pk2, sk1 == sk2) === (False, False)

-- Roundtrip test on the raw bindings.
prop_signMessage' :: ByteString -> Property
prop_signMessage' msg = testIO $ do
  (pk, sk) <- genKeyPair
  pure $ case signMessage' sk msg of
    Nothing' ->
      failWith $ "Unexpected failure signing: " <> T.pack (show msg)
    Just' sig ->
      (verifyMessage' pk sig msg) === Verified

return []
tests :: IO Bool
tests = $forAllProperties $ quickCheckWithResult (stdArgs { maxSuccess = 1000 } )
