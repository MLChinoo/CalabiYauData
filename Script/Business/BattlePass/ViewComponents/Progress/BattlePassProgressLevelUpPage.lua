local BattlePassProgressLevelUpPage = class("BattlePassProgressLevelUpPage", PureMVC.ViewComponentPage)
function BattlePassProgressLevelUpPage:ListNeededMediators()
  return {}
end
function BattlePassProgressLevelUpPage:InitializeLuaEvent()
end
function BattlePassProgressLevelUpPage:LuaHandleKeyEvent(key, inputEvent)
  if UE4.UKismetInputLibrary.Key_GetDisplayName(key) == "Escape" and inputEvent == UE4.EInputEvent.IE_Released then
    ViewMgr:ClosePage(self)
    return true
  end
  return false
end
function BattlePassProgressLevelUpPage:OnMouseButtonUp(MyGeometry, MouseEvent)
  ViewMgr:ClosePage(self)
  return true
end
function BattlePassProgressLevelUpPage:OnOpen(luaOpenData, nativeOpenData)
  if luaOpenData and luaOpenData.Level and self.Text_Level then
    self.Text_Level:SetText(luaOpenData.Level)
  end
  self:PlayAnimation(self.Anim_FadeIn, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function BattlePassProgressLevelUpPage:OnClose()
end
return BattlePassProgressLevelUpPage
