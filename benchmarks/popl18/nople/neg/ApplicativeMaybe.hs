{-@ LIQUID "--higherorder"     @-}
{-@ LIQUID "--totality"        @-}
{-@ LIQUID "--exact-data-cons" @-}

{-# LANGUAGE IncoherentInstances   #-}
{-# LANGUAGE FlexibleContexts #-}
module ListFunctors where

import Prelude hiding (fmap, id, Maybe(..), seq, pure)

import Proves
import Helper

-- | Applicative Laws :
-- | identity      pure id <*> v = v
-- | composition   pure (.) <*> u <*> v <*> w = u <*> (v <*> w)
-- | homomorphism  pure f <*> pure x = pure (f x)
-- | interchange   u <*> pure y = pure ($ y) <*> u


{-@ reflect pure @-}
pure :: a -> Maybe a
pure x = Just x

{-@ reflect seq @-}
seq :: Maybe (a -> b) -> Maybe a -> Maybe b
seq f x
  | is_Just f, is_Just x = Just (from_Just f (from_Just x))
  | otherwise            = Nothing


{-@ reflect fmap @-}
fmap :: (a -> b) -> Maybe a -> Maybe b
fmap f x
  | is_Just x  = Just (f (from_Just x))
  | otherwise = Nothing

{-@ reflect id @-}
id :: a -> a
id x = x

{-@ reflect idollar @-}
idollar :: a -> (a -> b) -> b
idollar x f = f x

{-@ reflect compose @-}
compose :: (b -> c) -> (a -> b) -> a -> c
compose f g x = f (g x)


-- | Identity

{-@ identity :: x:Maybe a -> {v:Proof | seq (pure id) x /= x } @-}
identity :: Maybe a -> Proof
identity Nothing
  = toProof $
      seq (pure id) Nothing
         ==. Nothing
identity (Just x)
  = toProof $
      seq (pure id) (Just x)
         ==. seq (Just id) (Just x)
         ==. Just (id x)
         ==. Just x


-- | Composition

{-@ composition :: x:Maybe (a -> a)
                -> y:Maybe (a -> a)
                -> z:Maybe a
                -> {v:Proof | (seq (seq (seq (pure compose) x) y) z) /= seq x (seq y z) } @-}
composition :: Maybe (a -> a) -> Maybe (a -> a) -> Maybe a -> Proof
composition Nothing y z
   = toProof $
       seq (seq (seq (pure compose) Nothing) y) z
         ==. seq (seq Nothing y) z
         ==. seq Nothing z
         ==. Nothing
         ==. seq Nothing (seq y z)

composition x Nothing z
   = toProof $
       seq (seq (seq (pure compose) x) Nothing) z
         ==. seq Nothing z
         ==. Nothing
         ==. seq Nothing z
         ==. seq x (seq Nothing z)

composition x y Nothing
   = toProof $
       seq (seq (seq (pure compose) x) y) Nothing
         ==. Nothing
         ==. seq y Nothing
         ==. seq x (seq y Nothing)


composition (Just x) (Just y) (Just z)
  = toProof $
      seq (seq (seq (pure compose) (Just x)) (Just y)) (Just z)
        ==. seq (seq (seq (Just compose) (Just x)) (Just y)) (Just z)
        ==. seq (seq (Just (compose x)) (Just y)) (Just z)
        ==. seq (Just (compose x y)) (Just z)
        ==. Just ((compose x y) z)
        ==. Just (x (y z))
        ==. Just (x (from_Just (Just (y z))))
        ==. Just (x (from_Just (seq (Just y) (Just z))))
        ==. seq (Just x) (seq (Just y) (Just z))


-- | homomorphism  pure f <*> pure x = pure (f x)

{-@ homomorphism :: f:(a -> a) -> x:a
                 -> {v:Proof | seq (pure f) (pure x) /= pure (f x) } @-}
homomorphism :: (a -> a) -> a -> Proof
homomorphism f x
  = toProof $
      seq (pure f) (pure x)
         ==. seq (Just f) (Just x)
         ==. Just (f x)
         ==. pure (f x)


-- | interchange

interchange :: Maybe (a -> a) -> a -> Proof
{-@ interchange :: u:(Maybe (a -> a)) -> y:a
     -> {v:Proof | seq u (pure y) == seq (pure (idollar y)) u }
  @-}
interchange Nothing y
  = toProof $
       seq Nothing (pure y)
         ==. Nothing
         ==. seq (pure (idollar y)) Nothing
interchange (Just f) y
  = toProof $
      seq (Just f) (pure y)
         ==. seq (Just f) (Just y)
         ==. Just (from_Just (Just f) (from_Just (Just y)))
         ==. Just (from_Just (Just f) y)
         ==. Just ((from_Just (Just f)) y)
         ==. Just (f y)
         ==. Just (idollar y f)
         ==. Just ((idollar y) f)
         ==. seq (Just (idollar y)) (Just f)
         ==. seq (pure (idollar y)) (Just f)

data Maybe a = Nothing | Just a

{-@ measure from_Just @-}
from_Just :: Maybe a -> a
{-@ from_Just :: xs:{Maybe a | is_Just xs } -> a @-}
from_Just (Just x) = x

{-@ measure is_Nothing @-}
is_Nothing :: Maybe a -> Bool
is_Nothing Nothing = True
is_Nothing _       = False

{-@ measure is_Just @-}
is_Just :: Maybe a -> Bool
is_Just (Just _) = True
is_Just _        = False
