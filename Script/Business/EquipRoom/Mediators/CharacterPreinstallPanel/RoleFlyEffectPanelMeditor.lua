local RoleTabBasePanelMeditor = require("Business/EquipRoom/Mediators/CharacterPreinstallPanel/RoleTabBasePanelMeditor")
local RoleFlyEffectPanelMeditor = class("RoleFlyEffectPanelMeditor", RoleTabBasePanelMeditor)
local RoleProxy, FlyEffectProxy
function RoleFlyEffectPanelMeditor:ListNotificationInterests()
  local list = RoleFlyEffectPanelMeditor.super.ListNotificationInterests(self)
  table.insert(list, NotificationDefines.EquipRoomUpdateRoleFlyEffectList)
  table.insert(list, NotificationDefines.OnResEquipFlyEffect)
  return list
end
function RoleFlyEffectPanelMeditor:OnRegister()
  RoleFlyEffectPanelMeditor.super.OnRegister(self)
  RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  FlyEffectProxy = GameFacade:RetrieveProxy(ProxyNames.RoleFlyEffectProxy)
end
function RoleFlyEffectPanelMeditor:OnRemove()
  RoleFlyEffectPanelMeditor.super.OnRemove(self)
end
function RoleFlyEffectPanelMeditor:HandleNotification(notify)
  RoleFlyEffectPanelMeditor.super.HandleNotification(self, notify)
  if self.bShow == false then
    return
  end
  local notifyName = notify:GetName()
  local notifyBody = notify:GetBody()
  if notifyName == NotificationDefines.EquipRoomUpdateRoleFlyEffectList then
    self:UpdateRoleFlyEffectList(notifyBody)
  elseif notifyName == NotificationDefines.OnResEquipFlyEffect then
    self:OnResEquipFlyEffect(notifyBody)
  end
end
function RoleFlyEffectPanelMeditor:OnShowPanel()
  RoleFlyEffectPanelMeditor.super.OnShowPanel(self)
  self:ClearPanel()
  self:SendUpdateRoleFlyEffectListCmd()
end
function RoleFlyEffectPanelMeditor:OnHidePanel()
  RoleFlyEffectPanelMeditor.super.OnHidePanel(self)
end
function RoleFlyEffectPanelMeditor:SendUpdateRoleFlyEffectListCmd()
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleFlyEffectListCmd)
end
function RoleFlyEffectPanelMeditor:UpdateRoleFlyEffectList(data)
  local itemListPanel = self:GetViewComponent().ItemListPanel
  if itemListPanel then
    itemListPanel:UpdatePanel(data)
    itemListPanel:UpdateItemNumStr(data)
    itemListPanel:SetDefaultSelectItem(1)
  end
end
function RoleFlyEffectPanelMeditor:OnItemClick(itemID)
  if self:GetViewComponent().ItemListPanel == nil then
    return
  end
  self:UpdateItemRedDot()
  if self.lastSelectItemID == itemID then
    return
  end
  self.lastSelectItemID = itemID
  self:SendUpdateItemDescCmd(self.lastSelectItemID, UE4.EItemIdIntervalType.FlyEffect)
  self:SendUpdateItemOperateSatateCmd(itemID)
  GameFacade:SendNotification(NotificationDefines.EquipRoomSwitchFlyEffect, itemID)
end
function RoleFlyEffectPanelMeditor:SendUpdateItemOperateSatateCmd(itemID)
  local body = {}
  body.itemType = UE4.EItemIdIntervalType.FlyEffect
  body.itemID = itemID
  GameFacade:SendNotification(NotificationDefines.GetItemOperateStateCmd, body)
end
function RoleFlyEffectPanelMeditor:UpdateItemOperateState(data)
  self:GetViewComponent():UpdateItemOperateState(data)
end
function RoleFlyEffectPanelMeditor:OnEquipClick()
  local item = self:GetViewComponent():GetSelectItem()
  if item then
    local itemID = item:GetItemID()
    FlyEffectProxy:ReqEquipFlyEffect(itemID)
  end
end
function RoleFlyEffectPanelMeditor:PlayVideo(videoURL)
  self:GetViewComponent():PlayVideo(videoURL, true)
end
function RoleFlyEffectPanelMeditor:OnResEquipFlyEffect(data)
  self:SendUpdateRoleFlyEffectListCmd()
  self:SendUpdateItemOperateSatateCmd(data)
end
function RoleFlyEffectPanelMeditor:OnBuyGoodsSuccessed(data)
  self:OnEquipClick()
end
function RoleFlyEffectPanelMeditor:UpdateItemRedDot()
  if self:GetViewComponent().ItemListPanel then
    local redDotId = self:GetViewComponent().ItemListPanel:GetSelectItemRedDotID()
    if nil ~= redDotId and 0 ~= redDotId then
      GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):ReadRedDot(redDotId)
      self:GetViewComponent().ItemListPanel:SetSelectItemRedDotID(0)
      RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomFlyEffect, -1)
    end
  end
end
return RoleFlyEffectPanelMeditor
