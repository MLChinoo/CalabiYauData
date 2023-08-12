local KaChatPanel = class("KaChatPanel", PureMVC.ViewComponentPanel)
local KaChatMediator = require("Business/KaPhone/Mediators/KaChatMediator")
local Valid
function KaChatPanel:GetIsActive()
  return self.IsActive
end
function KaChatPanel:SetIsActive(IsActive)
  self.IsActive = IsActive
end
function KaChatPanel:UpdateList(PackageData)
  local NewChatItemListData = PackageData.NewData
  local ChatItemListData = PackageData.ReadData
  Valid = self.DynamicEntryBox and self.DynamicEntryBox:Reset(true)
  if ChatItemListData or NewChatItemListData then
    local KaChatProxy = GameFacade:RetrieveProxy(ProxyNames.KaChatProxy)
    for FirstRowName, ChatItemData in pairsByKeys(NewChatItemListData or {}, function(a, b)
      if KaChatProxy:GetLatestFirstRowName(a) == KaChatProxy:GetLatestFirstRowName(b) then
        return a < b
      else
        return KaChatProxy:GetLatestFirstRowName(a) > KaChatProxy:GetLatestFirstRowName(b)
      end
    end) do
      local ChatItem = self.DynamicEntryBox and self.DynamicEntryBox:BP_CreateEntry()
      ChatItem:InitItem(ChatItemData)
    end
    for FirstRowName, ChatItemData in pairsByKeys(ChatItemListData or {}, function(a, b)
      return KaChatProxy:GetLatestFirstRowName(a) > KaChatProxy:GetLatestFirstRowName(b)
    end) do
      local ChatItem = self.DynamicEntryBox and self.DynamicEntryBox:BP_CreateEntry()
      ChatItem:InitItem(ChatItemData)
    end
  end
end
function KaChatPanel:UpdateChatDetail(CurSecondListMap, ChatDetailName)
  Valid = self.ChatDetailPanel and self.ChatDetailPanel:Update(CurSecondListMap, ChatDetailName)
  Valid = self.WidgetSwitcher and self.WidgetSwitcher:SetActiveWidgetIndex(1)
end
function KaChatPanel:ListNeededMediators()
  return {KaChatMediator}
end
function KaChatPanel:Construct()
  KaChatPanel.super.Construct(self)
  Valid = self.DynamicEntryBox and self.DynamicEntryBox:Reset(true)
  Valid = self.WidgetSwitcher and self.WidgetSwitcher:SetActiveWidgetIndex(0)
end
function KaChatPanel:Destruct()
  Valid = self.DynamicEntryBox and self.DynamicEntryBox:Reset(true)
  KaChatPanel.super.Destruct(self)
end
return KaChatPanel
