# dmgbuild settings for the styled HarvestPlus install DMG.
# Invoked with defines: app=<path to .app>, background=<path to background.png>.
# Produces a 600x400 window, 128px icons, app on the left, Applications on the
# right, with the background image drawn behind them.
import os

application = defines["app"]
appname = os.path.basename(application)
background = defines["background"]

format = "UDZO"                       # compressed, read-only
files = [application]
symlinks = {"Applications": "/Applications"}

default_view = "icon-view"
show_status_bar = False
show_tab_view = False
show_toolbar = False
show_pathbar = False
show_sidebar = False

window_rect = ((220, 200), (600, 400))   # (x, y), (width, height)
icon_size = 128
text_size = 13

icon_locations = {
    appname: (160, 200),
    "Applications": (440, 200),
}
