{-@ LIQUID "--higherorder"     @-}

{-@ LIQUID "--autoproofs"      @-}
{-@ LIQUID "--exact-data-cons" @-}

{-# LANGUAGE IncoherentInstances   #-}

module Compose where

import Prelude hiding (map)

import Proves

{-@ axiomatize compose @-}
compose :: (b -> c) -> (a -> b) -> a -> c
compose f g x = f (g x)


{-@ prop1 :: f:(a -> a) -> g:(a -> a) -> x:a
          -> {v: Proof | f (g x) == compose f g x } @-}
prop1 :: (a -> a) -> (a -> a) -> a -> Proof 
prop1 f g x
  = toProof $ 
      compose f g x ==. f (g x)


{-@ prop2 :: f:(a -> a) -> g:(a -> a) -> x:a
          -> {v: Proof | compose f g x == compose f g x } @-}
prop2 :: (a -> a) -> (a -> a) -> a -> Proof 
prop2 f g x
  = toProof $ 
      compose f g x ==. f (g x)