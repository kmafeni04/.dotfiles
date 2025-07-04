local wezterm = require("wezterm")
local act = wezterm.action

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.enable_wayland = false
config.window_decorations = "NONE"
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
config.font = wezterm.font_with_fallback({
  "DejaVuSansM Nerd Font Mono",
  "JetBrains Mono",
})

config.enable_scroll_bar = false

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
    action = act.OpenLinkAtMouseCursor,
  },
  -- Disable the 'Down' event of CTRL-Click to avoid weird program behaviors
  {
    event = { Down = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = act.Nop,
  },
}

config.keys = {
  {
    key = "w",
    mods = "CTRL",
    action = wezterm.action.CloseCurrentPane({ confirm = true }),
  },
  {
    key = "f",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SplitPane({
      direction = "Right",
      command = { args = { "yazi" } },
    }),
  },

  {
    key = "l",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SplitPane({
      direction = "Right",
    }),
  },
  {
    key = "h",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SplitPane({
      direction = "Left",
    }),
  },
  {
    key = "k",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SplitPane({
      direction = "Up",
    }),
  },
  {
    key = "j",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SplitPane({
      direction = "Down",
    }),
  },
}

local function is_shell(foreground_process_name)
  local shell_names = { "bash", "zsh", "fish", "sh", "ksh", "dash" }
  local process = string.match(foreground_process_name, "[^/\\]+$") or foreground_process_name
  for _, shell in ipairs(shell_names) do
    if process == shell then
      return true
    end
  end
  return false
end

-- https://wezterm.org/recipes/hyperlinks.html
wezterm.on("open-uri", function(window, pane, uri)
  local editor = "helix"

  if uri:find("^file:") == 1 and not pane:is_alt_screen_active() then
    -- We're processing an hyperlink and the uri format should be: file://[HOSTNAME]/PATH[#linenr]
    -- Also the pane is not in an alternate screen (an editor, less, etc)
    local url = wezterm.url.parse(uri)
    if is_shell(pane:get_foreground_process_name()) then
      -- A shell has been detected. Wezterm can check the file type directly
      -- figure out what kind of file we're dealing with
      local success, stdout, _ = wezterm.run_child_process({
        "file",
        "--brief",
        "--mime-type",
        url.file_path,
      })
      if success then
        if stdout:find("directory") then
          pane:send_text(wezterm.shell_join_args({ "cd", url.file_path }) .. "\r")
          pane:send_text(wezterm.shell_join_args({
            "ls",
            "-a",
            "-p",
            "--group-directories-first",
          }) .. "\r")
          return false
        end

        if stdout:find("text") then
          if url.fragment then
            pane:send_text(wezterm.shell_join_args({
              editor,
              "+" .. url.fragment,
              url.file_path,
            }) .. "\r")
          else
            pane:send_text(wezterm.shell_join_args({ editor, url.file_path }) .. "\r")
          end
          return false
        end
      end
    else
      -- No shell detected, we're probably connected with SSH, use fallback command
      local edit_cmd = url.fragment and editor .. " +" .. url.fragment .. ' "$_f"' or editor .. ' "$_f"'
      local cmd = '_f="'
        .. url.file_path
        .. '"; { test -d "$_f" && { cd "$_f" ; ls -a -p --hyperlink --group-directories-first; }; } '
        .. '|| { test "$(file --brief --mime-type "$_f" | cut -d/ -f1 || true)" = "text" && '
        .. edit_cmd
        .. "; }; echo"
      pane:send_text(cmd .. "\r")
      return false
    end
  end

  -- without a return value, we allow default actions
end)

return config
