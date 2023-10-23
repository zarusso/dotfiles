import XMonad
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.MouseResize (mouseResize)
import XMonad.Actions.Promote (promote)
import XMonad.Actions.SwapPromote (masterHistoryHook)
import XMonad.Actions.TopicSpace
import XMonad.Actions.UpdatePointer (updatePointer)
import XMonad.Actions.WithAll (killAll)

import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen)
import XMonad.Hooks.ManageDocks (avoidStruts, ToggleStruts(ToggleStruts))
import XMonad.Hooks.ManageHelpers (doFullFloat, isDialog, isFullscreen)
import XMonad.Hooks.StatusBar (withEasySB, statusBarProp)
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.UrgencyHook (withUrgencyHook, NoUrgencyHook(NoUrgencyHook))

import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.SpawnOnce (spawnOnce)

import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.ResizableTile (ResizableTall(ResizableTall), MirrorResize(MirrorShrink), MirrorResize(MirrorExpand))
import XMonad.Layout.PerWorkspace
import XMonad.Layout.SimplestFloat (simplestFloat)
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns (ThreeCol(ThreeCol))

import XMonad.Layout.LimitWindows (limitWindows)
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders (withBorder, smartBorders)
import XMonad.Layout.Renamed (renamed, Rename(Replace))
import XMonad.Layout.Spacing (spacing)
import XMonad.Layout.Gaps (gaps)
import XMonad.Layout.WindowArranger (windowArrange)
import XMonad.Layout.WindowNavigation (windowNavigation)
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))

import Colors.MyTheme

main :: IO ()
main = xmonad
     . ewmhFullscreen
     . ewmh
     . withUrgencyHook NoUrgencyHook
     . withEasySB (statusBarProp "~/.local/bin/xmobar" (pure def)) toggleStrutsKey
     $ myConfig
     where
        toggleStrutsKey :: XConfig Layout -> (KeyMask, KeySym)
        toggleStrutsKey XConfig{ modMask = m } = (m, xK_i)
  
myConfig = def
    { modMask               = mod4Mask      -- Rebind Mod to the Super key
    , borderWidth           = myBorderWidth
    , focusedBorderColor    = myFocusedBorderColor
    , normalBorderColor     = myNormalBorderColor
    , terminal              = myTerminal
    , startupHook           = myStartupHook
    , layoutHook            = myLayoutHook  -- Use custom layouts
    , manageHook            = myManageHook  -- Match on certain windows
    , workspaces            = topicNames topics
    , logHook               = workspaceHistoryHookExclude [scratchpadWorkspaceTag]
                            <> masterHistoryHook -- Remember where we've been² (for 'swapPromote').
                            <> updatePointer (0.5, 0.5) (0, 0)
    }
  `additionalKeysP` myKeys

myTopicConfig :: TopicConfig
myTopicConfig = def
  { topicDirs          = tiDirs    topics
  , topicActions       = tiActions topics
  , defaultTopicAction = const (pure ()) 
  , defaultTopic       = "1"
  }

t1 :: Topic
t1 = "1"

t2 :: Topic
t2 = "2"

t3 :: Topic
t3 = "3"

t4 :: Topic
t4 = "4"

t5 :: Topic
t5 = "5"

t6 :: Topic
t6 = "6"

t7 :: Topic
t7 = "7"

t8 :: Topic
t8 = "8"

t9 :: Topic
t9 = "9"

topics :: [TopicItem]
topics =
  [ noAction   t1 "." 
  , inHome     t2     (spawn "firefox")
  , noAction   t3 "."
  , noAction   t4 "."
  , noAction   t5 "."
  , noAction   t6 "."
  , noAction   t7 "."
  , noAction   t8 "."
  , noAction   t9 "."
  ]
  
spawnShell :: X ()
spawnShell = currentTopicDir myTopicConfig >>= spawnShellIn

spawnShellIn :: Dir -> X () 
spawnShellIn dir = spawn $ "alacritty --working-directory " ++ dir

goto :: Topic -> X ()
goto = switchTopic myTopicConfig

toggleTopic :: X ()
toggleTopic = switchNthLastFocusedByScreen myTopicConfig 1
 
shiftToLastTopic :: X ()
shiftToLastTopic = shiftNthLastFocused 1


myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "confirm"             --> doFloat
    , className =? "file_progress"       --> doFloat
    , className =? "dialog"              --> doFloat
    , className =? "download"            --> doFloat
    , className =? "error"               --> doFloat
    , className =? "notification"        --> doFloat
    , className =? "Pcmanfm"             --> doFloat
    , className =? "Xloadimage"          --> doFloat
    , className =? "firefox"             --> doShift "2"
    , className =? "Archlinux-logout.py" --> doFullFloat

    , isDialog                      --> doFloat
    , isFullscreen                  --> doFullFloat
    , namedScratchpadManageHook myScratchpads
    ]

myStartupHook :: X ()
myStartupHook = do
    spawnOnce "nitrogen --restore"
    spawnOnce "picom &"
    spawnOnce "volnoti"
    spawnOnce "~/.local/bin/launch-scripts"

myGaps = [(U,5),(L,5),(R,5),(D,5)]

tall       = renamed [Replace "tall"]
           $ avoidStruts
           $ windowNavigation
	   $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ limitWindows 12
           $ gaps myGaps
           $ spacing 5
           $ ResizableTall 1 (3/100) (1/2) []

monocle    = renamed [Replace "monocle"]
           $ avoidStruts
           $ windowNavigation
	   $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ limitWindows 20 Full

floats     = renamed [Replace "floats"]
           $ avoidStruts
	   $ smartBorders
           $ limitWindows 20 simplestFloat

grid     = renamed [Replace "grid"]
           $ avoidStruts
           $ windowNavigation
	   $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ limitWindows 12
           $ gaps myGaps
           $ spacing 5
           $ mkToggle (single MIRROR)
           $ Grid (16/10)

threeCol = renamed [Replace "threeCol"]
           $ avoidStruts
           $ windowNavigation
	   $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ gaps myGaps
           $ spacing 5
           $ limitWindows 4
           $ ThreeCol 1 (3/100) (1/2)

tabs     = renamed [Replace "tabs"]
           $ avoidStruts
	   $ smartBorders
           $ gaps [(L,5),(R,5),(U,10),(D,5)]
           $ tabbed shrinkText myTabTheme

-- setting colors for tabs layout and tabs sublayout.
myTabTheme = def { fontName            = "xft:Ubuntu:bold:size=9"
                 , activeColor         = bg
                 , inactiveColor       = bg
                 , activeBorderColor   = bg
                 , inactiveBorderColor = bg
                 , activeTextColor     = pink
                 , inactiveTextColor   = purple
                 }

-- The layout hook
myLayoutHook = mouseResize $ windowArrange $ T.toggleLayouts tall

             $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
                 where
                   myDefaultLayout =     withBorder myBorderWidth tall
                                     ||| monocle
                                     ||| floats
                                     ||| tabs
                                     ||| grid
                                     ||| threeCol

myTerminal :: String
myTerminal = "alacritty"

myBrowser :: String
myBrowser = "firefox"

myGuiEditor :: String
myGuiEditor = "codium"

myBorderWidth :: Dimension
myBorderWidth = 2

myScratchpads :: [NamedScratchpad]
myScratchpads = 
    [ NS "terminal"   spawnTerm    findTerm    floatSmallTop
    , NS "calculator" spawnCalc    findCalc    floatSmallMid
    , NS "htop"       spawnHtop    findHtop    floatBigTop
    , NS "spotify"    spawnSpotify findSpotify floatBigMid
    ]
  where
    floatBigMid = customFloating $ W.RationalRect y x w h
               where
                 h = 0.9
                 w = 0.9
                 x = 0.95 -h
                 y = 0.95 -w 
    floatSmallMid = customFloating $ W.RationalRect y x w h
               where
                 h = 0.5
                 w = 0.4
                 x = 0.75 -h
                 y = 0.70 -w
    floatBigTop = customFloating $ W.RationalRect y x w h
               where
                 h = 0.54
                 w = 0.459
                 x = 0.546 -h
                 y = 0.727 -w
    floatSmallTop = customFloating $ W.RationalRect y x w h
               where
                 h = 0.4
                 w = 0.459
                 x = 0.406 -h
                 y = 0.727 -w

    spawnTerm     = myTerminal ++ " -t termScratchPad"
    findTerm      = title =? "termScratchPad"

    spawnCalc     = "qalculate-gtk"
    findCalc      = className =? "Qalculate-gtk"

    spawnHtop     = myTerminal ++ " -t htop -e htop"
    findHtop      = title =? "htop"

    spawnSpotify  = "spotify"
    findSpotify   = className =? "Spotify"


    
-- START_KEYS
type Keybinding = (String, X ())
type Keybindings = [Keybinding]

myKeys :: Keybindings
myKeys = concat
  [ xmonadKeys
  , appKeys
  , rofiKeys
  , notiKeys
  , multimediaKeys
  , windowKeys
  , scratchpadKeys
  , topicKeys
  , layoutKeys
  ]

-- | Xmonad keys
xmonadKeys :: Keybindings
xmonadKeys =
  [ ("M-C-r", spawn "xmonad --recompile")       -- Recompiles xmonad
  , ("M-S-r", spawn "xmonad --restart"  )       -- Restarts xmonad
  , ("M-S-q", io exitSuccess            )       -- Quits xmonad
  ]

appKeys :: Keybindings
appKeys =
  [ ("M-<Return>", spawnShell              )
  , ("M-c"       , spawn myGuiEditor       )
  , ("M-b"       , spawn myBrowser         )
  , ("M-x"	 , spawn "archlinux-logout")
  ]

rofiKeys :: Keybindings
rofiKeys =
  [ ("M-o"  , spawn "rofi -no-lazy-grab -show drun -modi run,drun,window -theme ~/.config/rofi/style/style -drun-icon-theme 'candy-icons'")
  ]

notiKeys :: Keybindings
notiKeys =
  [ ("M-n b"  , spawn "exec ~/.config/dunst/scripts/battery-noti")
  , ("M-n w"  , spawn "exec ~/.config/dunst/scripts/wifi-noti")
  ]

multimediaKeys :: Keybindings
multimediaKeys =
  [ ("<XF86AudioMute>"       , volume_toggle "; if amixer get Master | grep -Fq '[off]'; then volnoti-show -m; else volnoti-show $(amixer get Master | grep -Po '[0-9]+(?=%)' | tail -1); fi" )
  , ("<XF86AudioLowerVolume>" , volume "5%- unmute && volnoti-show $(amixer get Master | grep -Po '[0-9]+(?=%)' | tail -1)" ) 
  , ("<XF86AudioRaiseVolume>" , volume "5%+ unmute && volnoti-show $(amixer get Master | grep -Po '[0-9]+(?=%)' | tail -1)" )
  , ("<XF86MonBrightnessUp>"  , backlight "+5%"    )
  , ("<XF86MonBrightnessDown>", backlight "-5%"    )
  , ("<Print> 1"             , takeScreenshot         ) 
  , ("<Print> 2"             , takeScreenshotSelection)
  ]
 where
  volume :: String -> X ()
  volume = spawn . ("pactl set-sink-mute @DEFAULT_SINK@ 0 && amixer -q set Master " <>)

  volume_toggle :: String -> X ()
  volume_toggle = spawn . ("pactl set-sink-mute @DEFAULT_SINK@ toggle" <>)

  backlight :: String -> X ()
  backlight = spawn . ("xbacklight " <>)

  takeScreenshot = spawn "exec $HOME/.local/bin/screenshot 0"
  takeScreenshotSelection = spawn "exec $HOME/.local/bin/screenshot 1"

windowKeys :: Keybindings
windowKeys =
  [ ("M-q"         , kill1                   )   -- Kill the currently focused client
  , ("M-S-a"       , killAll                 )   -- Kill all windows on current workspace

  -- KB_GROUP Windows navigation
  , ("M-m"         , windows W.focusMaster   )   -- Move focus to the master window
  , ("M-k"         , windows W.focusDown     )   -- Move focus to the next window
  , ("M-j"         , windows W.focusUp       )   -- Move focus to the prev window
  , ("M-S-m"       , windows W.swapMaster    )   -- Swap the focused window and the master window
  , ("M-S-k"       , windows W.swapDown      )   -- Swap focused window with next window
  , ("M-S-j"       , windows W.swapUp        )   -- Swap focused window with prev window
  , ("M-<Backspace>", promote                 )   -- Moves focused window to master, others maintain order

  -- KB_GROUP Window resizing
  , ("M-h"         , sendMessage Shrink      )   -- Shrink horiz window width
  , ("M-l"         , sendMessage Expand      )   -- Expand horiz window width
  , ("M-M1-j"      , sendMessage MirrorShrink)   -- Shrink vert window width
  , ("M-M1-k"      , sendMessage MirrorExpand)   -- Expand vert window width
  ]

scratchpadKeys :: Keybindings
scratchpadKeys =
  [ ("M-s t", namedScratchpadAction myScratchpads "terminal"  )
  , ("M-s c", namedScratchpadAction myScratchpads "calculator")
  , ("M-s h", namedScratchpadAction myScratchpads "htop"     )
  , ("M-s s", namedScratchpadAction myScratchpads "spotify"   )
  ]

topicKeys :: Keybindings
topicKeys =
  [ ("M-a"      , currentTopicAction myTopicConfig)  
  , ("M-<Tab>"  , toggleTopic                     )  
  , ("M-S-<Tab>", shiftToLastTopic                ) 
  ]
  ++
  [ ("M-" ++ m ++ k, f i)
  | (i, k) <- zip (topicNames topics) (map show [1 .. 9 :: Int])
  , (f, m) <- [(goto, ""), (windows . W.shift, "S-")]
  ]


layoutKeys :: Keybindings
layoutKeys =
  [ ("M-t"  , switchToLayout "tall"    )
  , ("M-f"  , switchToLayout "floats"  )
  , ("M-v a", switchToLayout "tabs"    )
  , ("M-v m", switchToLayout "monocle" )
  , ("M-v g", switchToLayout "grid"    )
  , ("M-v 3", switchToLayout "threeCol")

  , ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts)
  ]
 where
   switchToLayout :: String -> X ()
   switchToLayout = sendMessage . JumpToLayout

-- END_KEYS
