local RoleTabBasePanelMeditor = require("Business/EquipRoom/Mediators/CharacterPreinstallPanel/RoleTabBasePanelMeditor")
local RoleVoicePanelMeditor = class("RoleVoicePanelMeditor", RoleTabBasePanelMeditor)
local RoleProxy
function RoleVoicePanelMeditor:ListNotificationInterests()
  local list = RoleVoicePanelMeditor.super.ListNotificationInterests(self)
  table.insert(list, NotificationDefines.EquipRoomUpdateRoleVoiceList)
  return list
end
function RoleVoicePanelMeditor:OnRegister()
  RoleVoicePanelMeditor.super.OnRegister(self)
  RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
end
function RoleVoicePanelMeditor:OnRemove()
  RoleVoicePanelMeditor.super.OnRemove(self)
  if self.PlayingAkTimer then
    self.PlayingAkTimer:EndTask()
    self.PlayingAkTimer = nil
  end
end
function RoleVoicePanelMeditor:HandleNotification(notify)
  RoleVoicePanelMeditor.super.HandleNotification(self, notify)
  if self.bShow == false then
    return
  end
  local notifyName = notify:GetName()
  local notifyBody = notify:GetBody()
  if notifyName == NotificationDefines.EquipRoomUpdateRoleVoiceList then
    self:UpdateRoleVoiceList(notifyBody)
  end
end
function RoleVoicePanelMeditor:OnShowPanel()
  RoleVoicePanelMeditor.super.OnShowPanel(self)
  self.bDefaultSelect = true
  self:ClearPanel()
  self:SendUpdateRoleVoiceListCmd()
end
function RoleVoicePanelMeditor:OnHidePanel()
  RoleVoicePanelMeditor.super.OnHidePanel(self)
  if self.PlayingID then
    UE4.UPMLuaAudioBlueprintLibrary.StopPlayingID(self.PlayingID)
    self.PlayingID = nil
  end
end
function RoleVoicePanelMeditor:SendUpdateRoleVoiceListCmd()
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleVoiceListCmd)
end
function RoleVoicePanelMeditor:UpdateRoleVoiceList(data)
  local itemListPanel = self:GetViewComponent().ItemListPanel
  if itemListPanel then
    itemListPanel:UpdatePanel(data)
    itemListPanel:UpdateItemNumStr(data)
    if self.bDefaultSelect then
      itemListPanel:SetDefaultSelectItem(1)
    end
    self.bDefaultSelect = true
  end
end
function RoleVoicePanelMeditor:OnItemClick(itemID)
  if self:GetViewComponent().ItemListPanel == nil then
    return
  end
  self:PlayRoleVoice(itemID)
  self:UpdateItemRedDot()
  if self.lastSelectItemID == itemID then
    return
  end
  self.lastSelectItemID = itemID
  self:SendUpdateItemDescCmd(self.lastSelectItemID, UE4.EItemIdIntervalType.RoleVoice)
  self:SendUpdateItemOperateSatateCmd(itemID)
end
function RoleVoicePanelMeditor:UpdateItemRedDot()
  if self:GetViewComponent().ItemListPanel then
    local redDotId = self:GetViewComponent().ItemListPanel:GetSelectItemRedDotID()
    if nil ~= redDotId and 0 ~= redDotId then
      GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy):RemoveLocalRedDot(redDotId, UE4.EItemIdIntervalType.RoleVoice)
      self:GetViewComponent().ItemListPanel:SetSelectItemRedDotID(0)
      RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomRoleVoice, -1)
    end
  end
end
function RoleVoicePanelMeditor:SendUpdateItemOperateSatateCmd(itemID)
  local body = {}
  body.itemType = UE4.EItemIdIntervalType.RoleVoice
  body.itemID = itemID
  GameFacade:SendNotification(NotificationDefines.GetItemOperateStateCmd, body)
end
function RoleVoicePanelMeditor:UpdateItemOperateState(data)
  self:GetViewComponent():UpdateItemOperateState(data)
end
function RoleVoicePanelMeditor:OnEquipClick()
  local item = self:GetViewComponent():GetSelectItem()
  if item then
    local itemID = item:GetItemID()
    self:PlayRoleVoiceByClick(itemID)
    self:UpdateItemRedDot()
  end
end
function RoleVoicePanelMeditor:UpdatePanelBySelctRoleID(roleID)
  RoleVoicePanelMeditor.super.UpdatePanelBySelctRoleID(self, roleID)
  self:ClearPanel()
  self:SendUpdateRoleVoiceListCmd()
end
function RoleVoicePanelMeditor:PlayRoleVoice(voiceID)
  if nil == voiceID then
    LogDebug("RoleVoicePanelMeditor:PlayRoleVoice", "voiceID is nil")
    return
  end
  if self.PlayingAkTimer then
    self.PlayingAkTimer:EndTask()
    self:SetPlayBtnState(false)
  end
  local roleVoiceRow = RoleProxy:GetRoleVoice(voiceID)
  if roleVoiceRow then
    if self:GetViewComponent().MainPage and self:GetViewComponent().MainPage.WBP_ItemDisplayKeys then
      self:GetViewComponent().MainPage.WBP_ItemDisplayKeys:SetItemDisplayed({itemId = voiceID, show3DBackground = true})
    end
    self:SetPlayBtnState(true)
    local audio = UE4.UPMLuaAudioBlueprintLibrary
    local duration = audio.GetAkEventMinimumDuration(roleVoiceRow.AkEvent)
    self.PlayingAkTimer = TimerMgr:AddTimeTask(duration, 0.0, 0, function()
      self:SetPlayBtnState(false)
      self.PlayingAkTimer = nil
    end)
  end
end
function RoleVoicePanelMeditor:PlayRoleVoiceByClick(voiceID)
  if nil == voiceID then
    LogDebug("RoleVoicePanelMeditor:PlayRoleVoice", "voiceID is nil")
    return
  end
  if self.PlayingAkTimer then
    self.PlayingAkTimer:EndTask()
    self:SetPlayBtnState(false)
  end
  local roleVoiceRow = RoleProxy:GetRoleVoice(voiceID)
  if roleVoiceRow then
    local audio = UE4.UPMLuaAudioBlueprintLibrary
    audio.StopPlayingID(self.PlayingID)
    if self:GetViewComponent().MainPage and self:GetViewComponent().MainPage.WBP_ItemDisplayKeys then
      self:GetViewComponent().MainPage.WBP_ItemDisplayKeys:PlayRoleVoice()
    end
    self:SetPlayBtnState(true)
    local audio = UE4.UPMLuaAudioBlueprintLibrary
    local duration = audio.GetAkEventMinimumDuration(roleVoiceRow.AkEvent)
    self.PlayingAkTimer = TimerMgr:AddTimeTask(duration, 0.0, 0, function()
      self:SetPlayBtnState(false)
      self.PlayingAkTimer = nil
    end)
  end
end
function RoleVoicePanelMeditor:SetPlayBtnState(bPlay)
  local text
  if bPlay then
    text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Palying")
  else
    text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Play")
  end
  self:GetViewComponent():SetEquipBtnName(text)
  self:GetViewComponent():SetEquipBtnState(not bPlay)
end
function RoleVoicePanelMeditor:PlayRandomAction(voiceID)
  local actionID = RoleProxy:GetRoleVoiceRandomActionID(voiceID)
  if actionID then
    LogDebug("RoleVoicePanelMeditor:PlayRandomAction", "start play RandomAction，Action ID : %s", actionID)
    GameFacade:SendNotification(NotificationDefines.EquipRoomPlayVoiceRandomAction, actionID)
  end
end
function RoleVoicePanelMeditor:OnBuyGoodsSuccessed(data)
  self.bDefaultSelect = false
  self:SendUpdateRoleVoiceListCmd()
  local itemListPanel = self:GetViewComponent().ItemListPanel
  if itemListPanel then
    itemListPanel:SetSelectedStateByItemID(self.lastSelectItemID)
    self:UpdateItemRedDot()
  end
  self:SendUpdateItemDescCmd(self.lastSelectItemID, UE4.EItemIdIntervalType.RoleVoice)
  self:SendUpdateItemOperateSatateCmd(self.lastSelectItemID)
end
return RoleVoicePanelMeditor
