local wezterm = require("wezterm")
local act = wezterm.action

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.enable_wayland = false
config.window_decorations = "RESIZE"
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

-- Modified from https://wezterm.org/recipes/hyperlinks.html

---@param foreground_process_name string
---@return boolean
local function is_shell(foreground_process_name)
  local shell_names = { "bash", "zsh", "fish", "sh", "ksh", "dash" }
  local process = foreground_process_name:match("[^/\\]+$") or foreground_process_name
  for _, shell in ipairs(shell_names) do
    if process == shell then
      return true
    end
  end
  return false
end

local URI_SEP <const> = "__;__"

---@param window table
---@param pane table
---@param uri string
---@return boolean?
local function open_uri(window, pane, uri)
  local editor_cmd = "hx"
  local editor_name = "helix"

  local tab = window:active_tab()
  local tab_panes = tab:panes()
  ---@type table?
  local editor_pane
  for _, tab_pane in ipairs(tab_panes) do
    -- NOTE: This is basically my print debugging
    -- wezterm.run_child_process({
    --   "notify-send",
    --   ('"EXEC: %s"'):format((tab_pane:get_foreground_process_info() or {}).executable),
    -- })
    if (tab_pane:get_foreground_process_info() or {}).name == editor_name then
      editor_pane = tab_pane
      break
    end
  end

  local actual_uri, line_num, char_num = uri:match("(.+)" .. URI_SEP .. "(.+)" .. URI_SEP .. "(.*)")

  uri = (actual_uri and type(actual_uri) == "string" and actual_uri ~= "") and actual_uri or uri
  line_num = (line_num and type(line_num) == "string" and line_num ~= "") and line_num or "1"
  char_num = (char_num and type(char_num) == "string" and char_num ~= "") and char_num or "1"

  local url = wezterm.url.parse(uri)

  if not is_shell(pane:get_foreground_process_name()) then
    return
  end

  local path = url.file_path .. ":" .. line_num .. ":" .. char_num
  -- A shell has been detected. Wezterm can check the file type directly
  -- figure out what kind of file we're dealing with
  local ok, stdout, _ = wezterm.run_child_process({
    "mimetype",
    " --output-format",
    "%m",
    url.file_path,
  })
  if not ok then
    return
  end

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

  if stdout:find("text/") then
    if editor_pane then
      editor_pane:send_text(":o " .. path .. "\r")
      return false
    end

    local top_pane = tab:get_pane_direction("Up")

    if not top_pane then
      ---@type table?
      top_pane = pane:split({ direction = "Top", size = 0.7 })

      if not top_pane then
        return
      end
    end

    top_pane:activate()

    if not url.fragment then
      top_pane:send_text(wezterm.shell_join_args({ editor_cmd, path }) .. "\r")
      return false
    end

    top_pane:send_text(wezterm.shell_join_args({
      editor_cmd,
      "+" .. url.fragment,
      path,
    }) .. "\r")
    return false
  end
end

--- Without a return value, we allow default actions
---@param window table
---@param pane table
---@param uri string
---@return boolean?
local function on_open_uri(window, pane, uri)
  if uri:match("^http[s]?") then
    return
  end
  if uri:find("^file:") == 1 and not pane:is_alt_screen_active() then
    return open_uri(window, pane, uri)
  else
    local new_uri
    if uri:match("^/") then
      new_uri = "file://" .. uri
    else
      local cwd = pane:get_current_working_dir()
      new_uri = tostring(cwd) .. uri
    end
    return open_uri(window, pane, new_uri)
  end
end

wezterm.on("open-uri", on_open_uri)

config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- File paths with line_num and optional char_num
config.hyperlink_rules[#config.hyperlink_rules + 1] = {
  regex = "\\s*([^\r\n:]+):(\\d+):(\\d*)\\s*",
  format = "$1" .. URI_SEP .. "$2" .. URI_SEP .. "$3",
}

return config
