--- change number of columns in small windows
function Tab:layout()
  if self._area.w > 80 then
    self._chunks = ui.Layout()
      :direction(ui.Layout.HORIZONTAL)
      :constraints({
        ui.Constraint.Ratio(rt.mgr.ratio.parent, rt.mgr.ratio.all),
        ui.Constraint.Ratio(rt.mgr.ratio.current, rt.mgr.ratio.all),
        ui.Constraint.Ratio(rt.mgr.ratio.preview, rt.mgr.ratio.all),
      })
      :split(self._area)
  elseif self._area.w > 40 then
    self._chunks = ui.Layout()
      :direction(ui.Layout.HORIZONTAL)
      :constraints({
        ui.Constraint.Ratio(0, rt.mgr.ratio.all),
        ui.Constraint.Ratio(rt.mgr.ratio.current + rt.mgr.ratio.parent, rt.mgr.ratio.all),
        ui.Constraint.Ratio(rt.mgr.ratio.preview + rt.mgr.ratio.parent, rt.mgr.ratio.all),
      })
      :split(self._area)
  else
    self._chunks = ui.Layout()
      :direction(ui.Layout.HORIZONTAL)
      :constraints({
        ui.Constraint.Ratio(0, rt.mgr.ratio.all),
        ui.Constraint.Ratio(rt.mgr.ratio.all, rt.mgr.ratio.all),
        ui.Constraint.Ratio(0, rt.mgr.ratio.all),
      })
      :split(self._area)
  end
end

return {}
