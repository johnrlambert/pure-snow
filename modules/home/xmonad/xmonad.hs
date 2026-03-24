import XMonad
import XMonad.Layout.Spiral
import XMonad.Layout.Spacing

mySpacing :: Integer -> l a -> XMonad.Layout.ModifiedLayout Spacing l a
mySpacing i = spacingRaw True (Border i i i i) True (Border i i i i) True

main :: IO ()
main = xmonad def
  { terminal = "alacritty"
  , modMask = mod4Mask
  , layoutHook = mySpacing 5 $ spiral (6/7)
  }
