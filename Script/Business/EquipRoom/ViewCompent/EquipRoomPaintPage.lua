local EquipRoomPaintPageMediator = require("Business/EquipRoom/Mediators/EquipRoomPaintPageMediator")
local EquipRoomPaintPage = class("EquipRoomPaintPage", PureMVC.ViewComponentPage)
function EquipRoomPaintPage:ListNeededMediators()
  return {EquipRoomPaintPageMediator}
end
function EquipRoomPaintPage:InitializeLuaEvent()
  if self.WBP_UI3DModelControlWidget then
    self.WBP_UI3DModelControlWidget.actionOnReturn:Add(self.ColsePage, self)
  end
  self.onCloseAnimationFinishEvent = LuaEvent.new()
  self:ShowDecalShortcutKey()
end
function EquipRoomPaintPage:OnOpen(luaOpenData, nativeOpenData)
  self.ViewSwtichAnimation:PlayOpenAnimation({
    self,
    self.OnOpenAnimationFinish
  })
end
function EquipRoomPaintPage:OnClose()
  if self.WBP_UI3DModelControlWidget then
    self.WBP_UI3DModelControlWidget.actionOnReturn:Remove(self.ColsePage, self)
  end
end
function EquipRoomPaintPage:OnOpenAnimationFinish()
end
function EquipRoomPaintPage:ColsePage()
  self.ViewSwtichAnimation:PlayCloseAnimation({
    self,
    self.OnCloseAnimationFinish
  })
end
function EquipRoomPaintPage:OnCloseAnimationFinish()
  self.onCloseAnimationFinishEvent()
end
function EquipRoomPaintPage:UpdateGridPanel(PanelDatas)
  self.GridsPanel:UpdatePanel(PanelDatas)
  self.GridsPanel:UpdateItemNumStr(PanelDatas)
end
function EquipRoomPaintPage:ShowPaint(PainData)
  if self.WBP_UI3DModelControlWidget then
    self.WBP_UI3DModelControlWidget:SetItemDisplayed({
      itemId = PainData.itemID
    })
  end
  self.ItemDescPanel:UpdatePanel(PainData)
end
function EquipRoomPaintPage:SetDefaultSelectItem(defaultSelectIndex)
  if nil ~= defaultSelectIndex then
    self.GridsPanel:SetDefaultSelectItem(defaultSelectIndex)
  end
end
function EquipRoomPaintPage:LuaHandleKeyEvent(key, inputEvent)
  if self.WBP_UI3DModelControlWidget then
    return self.WBP_UI3DModelControlWidget:LuaHandleKeyEvent(key, inputEvent)
  end
  return false
end
function EquipRoomPaintPage:ShowDecalShortcutKey()
  if self.DecalDropSlotPanel then
    local inputKey = UE4.UPMInputSubsystem.Get(LuaGetWorld()):GetActionMappingByInputName("Graffiti", 0)
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "KeyTips")
    local stringMap = {
      ["0"] = inputKey
    }
    local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    self.DecalDropSlotPanel:ShowDecalShortcutKey(text)
  end
end
function EquipRoomPaintPage:ReturnPage()
  ViewMgr:ClosePage(self)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, true)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, false)
end
return EquipRoomPaintPage
