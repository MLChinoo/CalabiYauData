local ShortcutTaskItem = class("ShortcutTaskItem", PureMVC.ViewComponentPanel)
function ShortcutTaskItem:UpdateView(data)
  self.Txt_Desc:SetText(data.desc)
  if data.prize then
    self.Txt_Prize:SetText("+" .. data.prize .. ConfigMgr:FromStringTable(StringTablePath.ST_BattlePass, "Experience"))
  end
  self.Txt_Progress_Cur:SetText(data.value)
  self.Txt_Progress_Tar:SetText(data.targetValue)
  self.PB_Progress:SetPercent(data.value / data.targetValue)
  if data.state >= 3 then
    self.Switcher_Progress:SetActiveWidgetIndex(1)
  end
end
return ShortcutTaskItem
