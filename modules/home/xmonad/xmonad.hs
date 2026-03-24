import XMonad
import XMonad.Layout.Spiral
import XMonad.Layout.Spacing (spacingRaw, Border(..), Spacing)
import XMonad.Layout.LayoutModifier (ModifiedLayout)
import XMonad.Hooks.ManageDocks
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig (additionalKeys)

mySpacing :: Integer -> l a -> ModifiedLayout Spacing l a
mySpacing i = spacingRaw True (Border i i i i) True (Border i i i i) True

main :: IO ()
main = xmonad $ docks def
  { terminal = "alacritty"
  , modMask = mod4Mask
  , layoutHook = mySpacing 5 $ spiral (6/7)
  }
  `additionalKeys`
  [ ((mod1Mask, xK_Tab), windows W.focusDown)
  , ((mod1Mask .|. shiftMask, xK_Tab), windows W.focusUp)
  , ((mod1Mask, xK_F4), kill)
  ]
