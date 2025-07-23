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

local URI_SEP <const> = "__;__"

-- Modified from https://wezterm.org/recipes/hyperlinks.html
local function open_uri(window, pane, uri)
  local editor = "helix"

  local tab = window:active_tab()
  local tab_panes = tab:panes()
  local helix_pane
  for _, tab_pane in ipairs(tab_panes) do
    -- wezterm.run_child_process({
    --   "notify-send",
    --   ('"EXEC: %s"'):format((tab_pane:get_foreground_process_info() or {}).executable),
    -- })
    if (tab_pane:get_foreground_process_info() or {}).name == "helix" then
      helix_pane = tab_pane
      break
    end
  end

  local actual_uri, line_num, char_num = uri:match("(.+)" .. URI_SEP .. "(.+)" .. URI_SEP .. "(.*)")
  uri = actual_uri or uri
  line_num = (line_num and type(line_num) == "string" and line_num ~= "") and line_num or "1"
  char_num = (char_num and type(char_num) == "string" and char_num ~= "") and char_num or "1"

  -- We're processing an hyperlink and the uri format should be: file://[HOSTNAME]/PATH[#linenr]
  -- Also the pane is not in an alternate screen (an editor, less, etc)
  local url = wezterm.url.parse(uri)
  if is_shell(pane:get_foreground_process_name()) then
    local path = url.file_path .. ":" .. line_num .. ":" .. char_num
    -- A shell has been detected. Wezterm can check the file type directly
    -- figure out what kind of file we're dealing with
    local success, stdout, _ = wezterm.run_child_process({
      "mimetype",
      " --output-format",
      "%m",
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

      if stdout:find("text/") then
        if helix_pane then
          helix_pane:send_text(":o " .. path .. "\r")
          return false
        end
        local new_pane = pane:split({ direction = "Top", size = 0.6 })
        if not new_pane then
          return
        end
        new_pane:activate()
        if url.fragment then
          new_pane:send_text(wezterm.shell_join_args({
            editor,
            "+" .. url.fragment,
            path,
          }) .. "\r")
        else
          new_pane:send_text(wezterm.shell_join_args({ editor, path }) .. "\r")
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

local function on_open_uri(window, pane, uri)
  if uri:find("^file:") == 1 and not pane:is_alt_screen_active() then
    return open_uri(window, pane, uri)
  else
    local new_uri = ""
    if uri:match("^/") then
      new_uri = "file://" .. uri
    else
      local cwd = pane:get_current_working_dir()
      new_uri = tostring(cwd) .. uri
    end
    return open_uri(window, pane, new_uri)
  end

  -- without a return value, we allow default actions
end

wezterm.on("open-uri", on_open_uri)

config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- File paths with line_num and char_num
config.hyperlink_rules[#config.hyperlink_rules + 1] = {
  regex = "^\\s*([^\r\n:]+):(\\d+):(\\d*)\\s*",
  format = "$1" .. URI_SEP .. "$2" .. URI_SEP .. "$3",
}

return config
