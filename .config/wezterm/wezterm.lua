local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.enable_wayland = true
-- config.window_decorations = "NONE"
config.font = wezterm.font("JetBrains Mono")
config.color_scheme = "Tokyo Night"
config.window_background_opacity = 0.8
config.enable_tab_bar = false
config.scrollback_lines = 1000000
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.font = wezterm.font_with_fallback {
	'DejaVuSansM Nerd Font Mono',
}

--config.enable_scroll_bar = true

config.skip_close_confirmation_for_processes_named = {
	"bash",
	"sh",
	"btop",
}

config.mouse_bindings = {
	-- Ctrl-click will open the link under the mouse cursor
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}


config.keys = {
	{
		key = 'w',
		mods = 'CTRL',
		action = wezterm.action.CloseCurrentPane { confirm = true },
	},
	{
		key = 'f',
		mods = 'CTRL|SHIFT',
		action = wezterm.action.SplitPane {
			direction = 'Right',
			command = { args = { 'yazi' } },
		},
	},

	{
		key = 'l',
		mods = 'CTRL|SHIFT',
		action = wezterm.action.SplitPane {
			direction = 'Right',
		},
	},
	{
		key = 'h',
		mods = 'CTRL|SHIFT',
		action = wezterm.action.SplitPane {
			direction = 'Left',
		},
	},
	{
		key = 'k',
		mods = 'CTRL|SHIFT',
		action = wezterm.action.SplitPane {
			direction = 'Up',
		},
	},
	{
		key = 'j',
		mods = 'CTRL|SHIFT',
		action = wezterm.action.SplitPane {
			direction = 'Down',
		},
	},
}


return config
