import XMonad
import XMonad.Layout.Spiral

main :: IO ()
main = xmonad def
  { terminal = "alacritty"
  , modMask = mod4Mask
  , layoutHook = spiral (6/7)
  }
