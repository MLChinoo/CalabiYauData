local ExchangePosPage = class("ExchangePosPage", PureMVC.ViewComponentPage)
local ExchangePosPageMediator = require("Business/Room/Mediators/TeamUpRoom/ExchangePosPageMediator")
function ExchangePosPage:ListNeededMediators()
  return {ExchangePosPageMediator}
end
function ExchangePosPage:OnInitialized()
  ExchangePosPage.super.OnInitialized(self)
end
function ExchangePosPage:InitializeLuaEvent()
  self.actionLuaHandleKeyEvent = LuaEvent.new()
  self.actionConfirm = LuaEvent.new()
  self.actionRefuse = LuaEvent.new()
  self.actionKeepIgnore = LuaEvent.new()
end
function ExchangePosPage:Construct()
  ExchangePosPage.super.Construct(self)
  self.Button_Accept.OnClickEvent:Add(self, self.OnClickAccept)
  self.Button_Ignore.OnClickEvent:Add(self, self.OnClickIgnore)
  self.Button_IgnoreAll.OnClickEvent:Add(self, self.OnClickIgnoreAll)
  self.CheckBox_KeepIgnore.OnCheckStateChanged:Add(self, self.OnCheckStateChangedKeepIgnore)
end
function ExchangePosPage:Destruct()
  ExchangePosPage.super.Destruct(self)
  self.Button_Accept.OnClickEvent:Remove(self, self.OnClickAccept)
  self.Button_Ignore.OnClickEvent:Remove(self, self.OnClickIgnore)
  self.Button_IgnoreAll.OnClickEvent:Remove(self, self.OnClickIgnoreAll)
  self.CheckBox_KeepIgnore.OnCheckStateChanged:Remove(self, self.OnCheckStateChangedKeepIgnore)
end
function ExchangePosPage:LuaHandleKeyEvent(key, inputEvent)
  return self.actionLuaHandleKeyEvent(key, inputEvent)
end
function ExchangePosPage:OnClickAccept()
  self.actionConfirm()
end
function ExchangePosPage:OnClickIgnore()
  self.actionRefuse()
end
function ExchangePosPage:OnClickIgnoreAll()
  ViewMgr:ClosePage(self)
end
function ExchangePosPage:OnCheckStateChangedKeepIgnore(bIsChecked)
  self.actionKeepIgnore(bIsChecked)
end
function ExchangePosPage:AddPlayerItem(applyInfoData)
  local value = self.WBP_ApplyPlayerItemList:AddPlayerItem(applyInfoData, 1)
  if value then
    value:SetButtonUpFunc(function(del)
      GameFacade:SendNotification(NotificationDefines.TeamRoom.OnRoomSwitchClickItemNtf, del)
    end)
    value:SetPlayerHeadIcon(applyInfoData.PlayerIcon)
    value:UpdatePlayerInfo(applyInfoData)
  end
  if 1 == #self.WBP_ApplyPlayerItemList.itemArr then
    self.WBP_ApplyPlayerItemList:SetSelectedByIndex(1)
  end
  self:RefreshButton()
end
function ExchangePosPage:RemoveEntryItem(item)
  self.WBP_ApplyPlayerItemList:RemovePlayerItem(item)
  self:RefreshButton()
end
function ExchangePosPage:RefreshButton()
  if #self.WBP_ApplyPlayerItemList.itemArr > 1 then
    self.Button_IgnoreAll:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif 1 == #self.WBP_ApplyPlayerItemList.itemArr then
    self.Button_IgnoreAll:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function ExchangePosPage:OnSelectPlayer(item)
  if self.currentSelectItem then
    self.currentSelectItem:SetSelectState(false)
  end
  self.currentSelectItem = item
  self.currentSelectItem:SetSelectState(true)
  self.WBP_ApplyPlayerItemList:OnSelectPlayer(item)
end
return ExchangePosPage
