import XMonad
import Graphics.X11.ExtraTypes.XF86 (xF86XK_Close)
import XMonad.Layout.Spiral
import XMonad.Layout.Spacing (spacingRaw, Border(..), Spacing)
import XMonad.Layout.LayoutModifier (ModifiedLayout)
import XMonad.Layout.NoBorders (noBorders)
import XMonad.Layout.ToggleLayouts (toggleLayouts, ToggleLayout(ToggleLayout))
import XMonad.Hooks.ManageDocks
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig (additionalKeys)

screenshotCommand :: String
screenshotCommand =
  "mkdir -p \"$HOME/Pictures/Screenshots\" && scrot \"$HOME/Pictures/Screenshots/%Y-%m-%d-%H%M%S.png\""

mySpacing :: Integer -> l a -> ModifiedLayout Spacing l a
mySpacing i = spacingRaw True (Border i i i i) True (Border i i i i) True

main :: IO ()
main = xmonad $ docks def
  { terminal = "kitty"
  , modMask = mod4Mask
  , layoutHook = avoidStruts $ toggleLayouts (noBorders Full) $ mySpacing 5 $ spiral (3/5)
  }
  `additionalKeys`
  [ ((mod1Mask, xK_Tab), windows W.focusDown)
  , ((mod1Mask .|. shiftMask, xK_Tab), windows W.focusUp)
  , ((mod1Mask, xK_F4), kill)
  , ((0, xF86XK_Close), kill)
  , ((0, xK_Print), spawn screenshotCommand)
  , ((mod4Mask .|. shiftMask, xK_c), kill)
  , ((mod4Mask, xK_f), sendMessage ToggleLayout)
  ]
