{-# LANGUAGE
    FlexibleContexts
  #-}

module HFlint.Test.FMPZ
where

import Data.Proxy
import Math.Structure.Tasty
import Test.Tasty ( testGroup, TestTree )
import qualified Math.Structure.Tasty

import HFlint.FMPZ
import HFlint.Test.FMPZ.Integer
import HFlint.FMPZ.Tasty.QuickCheck
import HFlint.FMPZ.Tasty.SmallCheck


tests :: TestTree
tests =
  testGroup "FMPZ Tests" $
  [ referenceIngeger
  , zeroOneUnitTests
  ]
  ++
  runTestsQSC
  [ isEuclideanDomain (Proxy :: Proxy FMPZ) ]
