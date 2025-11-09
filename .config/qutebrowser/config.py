import os

c = c  # noqa: F821 pylint: disable=E0602,C0103
config = config  # noqa: F821 pylint: disable=E0602,C0103

config.load_autoconfig()  # load settings done via the gui

fg = "#9ABDF5"
bg = "#1A1B26"
bg_alt = "#313349"

c.colors.statusbar.normal.bg = bg
c.colors.statusbar.normal.fg = fg

c.colors.statusbar.command.bg = bg
c.colors.statusbar.command.fg = fg

c.colors.statusbar.url.fg = fg
c.colors.statusbar.url.success.https.fg = fg
c.colors.statusbar.url.hover.fg = "cyan"

c.colors.tabs.bar.bg = bg

c.colors.tabs.even.bg = bg
c.colors.tabs.odd.bg = bg
c.colors.tabs.even.fg = fg
c.colors.tabs.odd.fg = fg

c.colors.tabs.selected.even.bg = bg_alt
c.colors.tabs.selected.odd.bg = bg_alt
c.colors.tabs.selected.even.fg = fg
c.colors.tabs.selected.odd.fg = fg

c.colors.tabs.pinned.even.bg = bg
c.colors.tabs.pinned.odd.bg = bg
c.colors.tabs.pinned.even.fg = fg
c.colors.tabs.pinned.odd.fg = fg
c.colors.tabs.pinned.selected.even.bg = bg_alt
c.colors.tabs.pinned.selected.odd.bg = bg_alt
c.colors.tabs.pinned.selected.even.fg = fg
c.colors.tabs.pinned.selected.odd.fg = fg

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
c.colors.webpage.darkmode.algorithm = "lightness-cielab"
c.colors.webpage.darkmode.policy.images = "never"
config.set("colors.webpage.darkmode.enabled", False, "file://*")
config.set(
    "colors.webpage.darkmode.enabled", False, "qute://pdfjs/web/viewer.html*"
)

c.statusbar.show = "always"
c.statusbar.padding = {"bottom": 5, "left": 5, "right": 5, "top": 5}

c.tabs.title.format = "{index} {audio}{current_title}"
c.tabs.title.format_pinned = "{index} {audio}"
c.tabs.show = "multiple"
c.tabs.padding = {"top": 7, "bottom": 7, "left": 10, "right": 10}
c.tabs.indicator.width = 0  # no tab indicators
c.tabs.width = "7%"

c.hints.border = bg
c.hints.uppercase = True

c.url.searchengines = {
    "DEFAULT": "https://duckduckgo.com/?q={}",
    "!aw": "https://wiki.archlinux.org/?search={}",
    "!apkg": "https://archlinux.org/packages/?sort=&q={}&maintainer=&flagged=",
    "!gh": "https://github.com/search?o=desc&q={}&s=stars",
    "!yt": "https://www.youtube.com/results?search_query={}",
}

# NOTE: Doesn't work and just crashes
# c.fileselect.handler = "external"
# c.fileselect.multiple_files.command = ['/home/kome/.scripts/qb-fileselect-lf.sh', 'files']
# c.fileselect.single_file.command = ['/home/kome/.scripts/qb-fileselect-lf.sh', 'file']
# c.fileselect.folder.command = ['notify-send', '"folder command. not working ATM. fix it somehow when you get to it." ']
# filepicker = [
#     "wezterm",
#     "-e",
#     "lf",
#     "-selection-path={}",
# ]
# c.fileselect.handler = "external"
# c.fileselect.folder.command = filepicker
# c.fileselect.multiple_files.command = filepicker
# c.fileselect.single_file.command = filepicker

c.completion.open_categories = [
    "searchengines",
    "quickmarks",
    "bookmarks",
    "history",
    "filesystem",
]

# misc
c.auto_save.session = True  # save tabs on quit/restart
c.session.lazy_restore = False  # Doesn't work with sessions if the browser is closed before opening the page
c.scrolling.smooth = True
c.scrolling.bar = "never"
c.zoom.mouse_divider = 512  # controls mouse zooming
c.content.autoplay = False
c.content.pdfjs = True

# binds
config.unbind("G")
config.unbind("gf")
config.unbind("sl")
config.unbind("wb")
config.unbind("<Alt-1>")
config.unbind("<Alt-2>")
config.unbind("<Alt-3>")
config.unbind("<Alt-4>")
config.unbind("<Alt-5>")
config.unbind("<Alt-6>")
config.unbind("<Alt-7>")
config.unbind("<Alt-8>")
config.unbind("<Alt-9>")

config.bind("<Space>f", "cmd-set-text -s :tab-select")

# In consideration
# config.bind("h", "scroll-px -50 0")
# config.bind("j", "scroll-px 0 50")
# config.bind("k", "scroll-px 0 -50")
# config.bind("l", "scroll-px 50 0")

config.bind("<Ctrl-n>", "open -t")
config.bind("<Ctrl-r>", "config-source;; message-info 'Config sourced'")
config.bind("<Ctrl-Shift-Tab>", "tab-prev")
config.bind("<Ctrl-Tab>", "tab-next")

config.bind("<Alt-q>", "tab-close")
config.bind("<Alt-b>", "tab-prev")
config.bind("<Alt-n>", "tab-next")
config.bind("<Alt-1>", "tab-prev")
config.bind("<Alt-2>", "tab-next")
config.bind("<Ctrl-1>", "tab-select 1")
config.bind("<Ctrl-2>", "tab-select 2")
config.bind("<Ctrl-3>", "tab-select 3")
config.bind("<Ctrl-4>", "tab-select 4")
config.bind("<Ctrl-5>", "tab-select 5")
config.bind("<Ctrl-6>", "tab-select 6")
config.bind("<Ctrl-7>", "tab-select 7")
config.bind("<Ctrl-8>", "tab-select 8")
config.bind("<Ctrl-9>", "tab-select 9")

config.bind("cm", "clear-messages")

config.bind("tt", "spawn --userscript translate")
config.bind("tg", "cmd-set-text -s :tab-give")
config.bind("th", "config-cycle tabs.show multiple never")

config.bind("0", "zoom")
config.bind("=", "zoom-in")

config.bind("wd", "config-cycle colors.webpage.darkmode.enabled")
config.bind("wbb", "spawn --userscript qute-bitwarden")
config.bind("wbu", "spawn --userscript qute-bitwarden --username-only")
config.bind("wbp", "spawn --userscript qute-bitwarden --password-only")

config.bind("gm", "tab-move")
config.bind("ge", "scroll-to-perc 100")
config.bind("gs", "view-source")
config.bind("gh", "tab-focus 1")
config.bind("gl", "tab-focus -1")

config.bind("sh", "config-cycle statusbar.show always never")
config.bind("ss", "cmd-set-text -s :session-save")
config.bind("slh", "session-save;; session-load home;; close")
config.bind("slw", "session-save;; session-load work;; close")
config.bind("sll", "session-save;; session-load lang-dev;; close")

config.bind(";d", "hint links spawn fdm -u {hint-url}")

# aliases
c.aliases["yt"] = "open https://www.youtube.com"
c.aliases["yt!"] = "open -t https://www.youtube.com"
c.aliases["gh"] = "open https://www.github.com"
c.aliases["gh!"] = "open -t https://www.github.com"
c.aliases["da"] = "open https://www.duck.ai"
c.aliases["da!"] = "open -t https://www.duck.ai"
c.aliases["nf"] = "open https://www.nerdfonts.com"
c.aliases["nf!"] = "open -t https://www.nerdfonts.com"

# fonts
session = os.getenv("XDG_SESSION_TYPE")
if session == "wayland":
    c.fonts.default_size = "20px"
    c.zoom.default = "125%"
else:
    c.fonts.default_size = "16px"
    c.zoom.default = "100%"
c.fonts.web.size.default = 20
c.fonts.default_family = ["DejaVuSansM Nerd Font"]
c.fonts.tabs.selected = "default_size default_family"
c.fonts.tabs.unselected = "default_size default_family"
c.fonts.tooltip = "default_size default_family"

# privacy
config.set("content.webgl", False, "*")
config.set("content.webgl", True, "www.figma.com")

config.set("content.canvas_reading", False)
config.set("content.canvas_reading", True, "www.figma.com")

config.set("input.mode_override", "passthrough", "www.figma.com")

config.set("content.cookies.accept", "all")
config.set("content.cookies.store", True)

config.set("content.geolocation", False)
config.set("content.webrtc_ip_handling_policy", "default-public-interface-only")

# Adblocking
c.content.blocking.enabled = True
c.content.blocking.method = "both"
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
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/unbreak.txt",
]
