{-# LANGUAGE
    FlexibleInstances
  #-}

module Flint.FMPZ
    ( FMPZ
    )
where

import Flint.Internal.FlintCalls
import Flint.FMPZ.FFI
    
import Foreign.C.Types (CULong(..))
import Foreign.C.String (peekCString)
import Foreign.Ptr (nullPtr)
import Foreign.Marshal (free)

import System.IO.Unsafe (unsafePerformIO)

instance Num FMPZ where
    -- todo : speed this up
    fromInteger a | a < 0 = negate (fromInteger (negate a))
                  | a == 0 = unsafePerformIO $ withNewFlint_ fmpz_zero
                  | otherwise = unsafePerformIO $
                                withNewFlint_ $ \cptr -> do
                                  fmpz_set_ui cptr $ head limbs
                                  flip mapM_ (tail limbs) $ \l -> do
                                    fmpz_mul_ui cptr cptr limbSize
                                    fmpz_add_ui cptr cptr l
                  where
                    limbSize = 1 + (div (maxBound :: CULong) 2)
                    limbs = map fromIntegral $
                            reverse $ map snd $ takeWhile (not . isZeroLimb) $
                            tail $ iterate nextLimb (a,0)
                    nextLimb = flip divMod (fromIntegral limbSize) . fst
                    isZeroLimb (b,l) = b==0 && l==0
    (+) = lift2Flint_ fmpz_add
    (-) = lift2Flint_ fmpz_sub
    (*) = lift2Flint_ fmpz_mul
    abs = liftFlint_ fmpz_abs
    signum = fromInteger . fromIntegral . unsafePerformIO . lift0Flint fmpz_sgn
    negate = liftFlint_ fmpz_neg


instance Show FMPZ where
    show = flip toString 10

toString :: FMPZ -> Int -> String
toString a base = unsafePerformIO $ do
  cstr <- lift0Flint (fmpz_get_str nullPtr (fromIntegral base)) a
  str <- peekCString cstr
  free cstr
  return str
