while true do
  local percent_program = io.popen([[upower -i `upower -e | grep 'BAT'` | grep -om 1 '\s*[0-9]*%']])
  local percent_read = string.gsub(assert(percent_program):read(), "%%", "")
  assert(percent_program):close()
  local state_program = io.popen([[upower -i `upower -e | grep 'BAT'` | grep 'state']])
  local state_read = string.gsub(assert(state_program):read(), "state:%s+", "")
  assert(state_program):close()
  local state = state_read:gsub("%s+", "")
  local percent = tonumber(percent_read)
  if state == "discharging" and percent <= 35 then
    os.execute([[zenity --warning --text "You're battery is running low, please recharge"]])
  end
  os.execute("sleep  60")
end
