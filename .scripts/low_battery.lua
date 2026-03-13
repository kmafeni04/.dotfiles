#!/usr/bin/env lua

while true do
  local percent_program <close> = io.popen([[upower -i `upower -e | grep 'BAT'` | grep -om 1 '\s*[0-9]*%']])
  local percent_read = string.gsub(assert(percent_program):read(), "%%", "")
  local state_program <close> = io.popen([[upower -i `upower -e | grep 'BAT'` | grep 'state']])
  local state_read = string.gsub(assert(state_program):read(), "state:%s+", "")
  local state = state_read:gsub("%s+", "")
  local percent = tonumber(percent_read)
  if state == "discharging" and percent <= 35 then
    os.execute(
      [[yad --text "<span font='monospace 25'>You're battery is running low, please recharge</span>" --justify center]]
    )
  end
  os.execute("sleep 60")
end
