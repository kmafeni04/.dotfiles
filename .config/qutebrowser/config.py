c = c  # noqa: F821 pylint: disable=E0602,C0103
config = config  # noqa: F821 pylint: disable=E0602,C0103

config.load_autoconfig() # load settings done via the gui

fg = "#9ABDF5"
bg = "#1A1B26"
bg_alt="#313349"

c.colors.statusbar.normal.bg = bg
c.colors.statusbar.command.bg = bg
c.colors.statusbar.command.fg = fg
c.colors.statusbar.normal.fg = fg
c.colors.statusbar.passthrough.fg = "red"
c.colors.statusbar.url.fg = fg
c.colors.statusbar.url.success.https.fg = fg
c.colors.statusbar.url.hover.fg = "cyan"

c.colors.tabs.pinned.even.bg = bg
c.colors.tabs.pinned.odd.bg = bg
c.colors.tabs.pinned.even.fg = fg
c.colors.tabs.pinned.odd.fg = fg
c.colors.tabs.pinned.selected.even.bg = bg_alt
c.colors.tabs.pinned.selected.odd.bg = bg_alt
c.colors.tabs.pinned.selected.even.fg = fg
c.colors.tabs.pinned.selected.odd.fg = fg

c.colors.tabs.even.bg = bg
c.colors.tabs.odd.bg = bg
c.colors.tabs.even.fg = fg
c.colors.tabs.odd.fg = fg
c.colors.tabs.selected.even.bg = bg_alt
c.colors.tabs.selected.odd.bg = bg_alt
c.colors.tabs.selected.even.fg = fg
c.colors.tabs.selected.odd.fg = fg

c.colors.hints.bg = fg
c.colors.hints.fg = bg

c.colors.completion.odd.bg = bg
c.colors.completion.even.bg = bg
c.colors.completion.fg = fg
c.colors.completion.category.bg = bg
c.colors.completion.category.fg = fg
c.colors.completion.item.selected.bg = bg
c.colors.completion.item.selected.fg = fg

c.colors.messages.info.bg = bg
c.colors.messages.info.fg = fg
c.colors.messages.error.bg = bg
c.colors.messages.error.fg = fg

c.colors.downloads.error.bg = bg
c.colors.downloads.error.fg = fg
c.colors.downloads.bar.bg = bg
c.colors.downloads.start.bg = fg
c.colors.downloads.start.fg = fg
c.colors.downloads.stop.bg = bg
c.colors.downloads.stop.fg = fg


c.colors.tooltip.bg = bg
c.colors.tooltip.fg = fg

c.colors.webpage.bg = bg
c.colors.webpage.preferred_color_scheme = "dark"

# dark mode setup
c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.algorithm = 'lightness-cielab'
c.colors.webpage.darkmode.policy.images = 'never'
config.set('colors.webpage.darkmode.enabled', False, 'file://*')

c.statusbar.show = "always"
c.statusbar.padding = {"bottom": 5, "left": 5, "right": 5, "top": 5}

c.tabs.title.format = "{audio}{current_title}"
c.tabs.show = "multiple"
c.tabs.padding = {'top': 7, 'bottom': 7, 'left': 10, 'right': 10}
c.tabs.indicator.width = 0 # no tab indicators
c.tabs.width = '7%'

c.tabs.title.format= "{index} {audio}{current_title}"
c.tabs.title.format_pinned = "{index}"

c.hints.border = fg

c.url.searchengines = {
    'DEFAULT': 'https://duckduckgo.com/?q={}',
    '!aw': 'https://wiki.archlinux.org/?search={}',
    '!apkg': 'https://archlinux.org/packages/?sort=&q={}&maintainer=&flagged=',
    '!gh': 'https://github.com/search?o=desc&q={}&s=stars',
    '!yt': 'https://www.youtube.com/results?search_query={}',
}

# c.fileselect.handler = "external"
# c.fileselect.multiple_files.command = ['/home/kome/.scripts/qb-fileselect-lf.sh', 'files']
# c.fileselect.single_file.command = ['/home/kome/.scripts/qb-fileselect-lf.sh', 'file']
# c.fileselect.folder.command = ['notify-send', '"folder command. not working ATM. fix it somehow when you get to it." ']

filepicker = [
    "wezterm",
    "-e",
    "lf",
    "-selection-path={}",
]
c.fileselect.handler = "external"
c.fileselect.folder.command = filepicker
c.fileselect.multiple_files.command = filepicker
c.fileselect.single_file.command = filepicker

c.completion.open_categories = ['searchengines', 'quickmarks', 'bookmarks', 'history', 'filesystem']

# misc
c.auto_save.session = True # save tabs on quit/restart
c.session.lazy_restore = True
c.scrolling.smooth = True
c.scrolling.bar = "never"
c.zoom.default = "125%"
c.zoom.mouse_divider = 0
# config.set('zoom.mouse_divider', 0, '*://figma.com/')
c.hints.uppercase = True

# keybinding changes
config.unbind("G")
config.unbind("gf")
config.unbind("sl")

config.bind('<Space>f', 'cmd-set-text -s :tab-select')

config.bind('<Ctrl-n>', 'open -t')
config.bind('<Ctrl-r>', 'config-source;; message-info \'Config refreshed\'')
config.bind('<Ctrl-Shift-Tab>', 'tab-prev')
config.bind('<Ctrl-Tab>', 'tab-next')

config.bind('<Alt-q>', 'tab-close')
config.bind('<Alt-1>', 'tab-prev')
config.bind('<Alt-2>', 'tab-next')
config.bind('<Alt-3>', 'tab-select 3')
config.bind('<Alt-4>', 'tab-select 4')
config.bind('<Alt-5>', 'tab-select 5')
config.bind('<Alt-6>', 'tab-select 6')
config.bind('<Alt-7>', 'tab-select 7')
config.bind('<Alt-8>', 'tab-select 8')
config.bind('<Alt-9>', 'tab-select 9')

config.bind('tt', 'spawn --userscript translate')
config.bind('th', 'config-cycle tabs.show multiple never')

config.bind('0', 'zoom')
config.bind('=', 'zoom-in')

config.bind('wd', 'config-cycle colors.webpage.darkmode.enabled')
config.bind('wb', 'spawn --userscript qute-bitwarden')

config.bind('gm', 'tab-move')
config.bind("ge", 'scroll-to-perc 100')
config.bind("gs", 'view-source')
config.bind("gh", 'tab-focus 1')
config.bind("gl", 'tab-focus -1')

config.bind('sh', 'config-cycle statusbar.show always never')
config.bind("ss", "cmd-set-text -s :session-save")
config.bind("sld", "session-save;; session-load default;; close")
config.bind("slw", "session-save;; session-load work;; close")
config.bind("sll", "session-save;; session-load lang-dev;; close")

# fonts
c.fonts.web.size.default = 20
c.fonts.default_family = ['DejaVuSansM Nerd Font']
c.fonts.default_size = '20px'
c.fonts.tabs.selected = 'default_size default_family'
c.fonts.tabs.unselected = 'default_size default_family'
# c.fonts.web.family.fixed = 'monospace'
# c.fonts.web.family.sans_serif = 'monospace'
# c.fonts.web.family.serif = 'monospace'
# c.fonts.web.family.standard = 'monospace'


# privacy - adjust these settings based on your preference
# config.set("completion.cmd_history_max_items", 0)
# config.set("content.private_browsing", True)
# config.set("content.webgl", False, "*")
# config.set("content.canvas_reading", False)
config.set("content.geolocation", False)
config.set("content.webrtc_ip_handling_policy", "default-public-interface-only")
config.set("content.cookies.accept", "all")
config.set("content.cookies.store", True)

# Adblocking info -->
# For yt ads: place the greasemonkey script yt-ads.js in your greasemonkey folder (~/.config/qutebrowser/greasemonkey).
# The script skips through the entire ad, so all you have to do is click the skip button.
# Yeah it's not ublock origin, but if you want a minimal browser, this is a solution for the tradeoff.
# You can also watch yt vids directly in mpv, see qutebrowser FAQ for how to do that.
# If you want additional blocklists, you can get the python-adblock package, or you can uncomment the ublock lists here.
c.content.blocking.enabled = True
# c.content.blocking.method = 'adblock' # uncomment this if you install python-adblock
c.content.blocking.adblock.lists = [
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/legacy.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2020.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2021.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2022.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2023.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2024.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2025.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/badware.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/privacy.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/badlists.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances-cookies.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances-others.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/badlists.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/quick-fixes.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/resource-abuse.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/unbreak.txt"
]
