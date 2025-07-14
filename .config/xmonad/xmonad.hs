import XMonad
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig (additionalKeysP)

main = xmonad $ def
    {
        modMask = mod4Mask
    }
      `additionalKeysP`
      [
        ("M-<Return>", spawn "exo-open --launch TerminalEmulator")
        ,("M-S-q", kill)
        ,("M-d", spawn "rofi -show drun")
        ,("C-<Space>", spawn "dunstctl close")
        ,("C-`", spawn "dunstctl history-pop")
        ,("C-S-.", spawn "dunstctl context")
        ,("M-<Down>", windows W.focusDown)
        ,("M-<Up>", windows W.focusUp)
        ,("M-S-r", spawn "xmonad --recompile && xmonad --restart")
      ]
