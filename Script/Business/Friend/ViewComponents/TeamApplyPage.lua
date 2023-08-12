local TeamApplyPageMediator = require("Business/Friend/Mediators/TeamApplyPageMediator")
local TeamApplyAndInviteBasePage = require("Business/Friend/ViewComponents/TeamApply/TeamApplyAndInviteBasePage")
local TeamApplyPage = class("TeamApplyPage", TeamApplyAndInviteBasePage)
local TeamApplyAndInviteProxy
function TeamApplyPage:ListNeededMediators()
  TeamApplyAndInviteProxy = GameFacade:RetrieveProxy(ProxyNames.TeamApplyAndInviteProxy)
  return {TeamApplyPageMediator}
end
function TeamApplyPage:ShowApplyPlayerInfo(playerInfoData)
  if self.ApplyPlayerInfo then
    self.ApplyPlayerInfo:UpdateInfo(playerInfoData)
  end
end
function TeamApplyPage:UpdatePanelInfo(playerInfoData)
  self:ShowApplyPlayerInfo(playerInfoData)
  self:SetTitle(playerInfoData.InviteType)
  self:SetRoomType(playerInfoData)
  self:SetArrowDirection(playerInfoData.InviteType)
end
function TeamApplyPage:RefreshButton()
  if self.Button_IgnoreAll then
    if self:GetEntryNum() > 1 then
      self.HorizontalBox_Timer.Slot:SetHorizontalAlignment(UE4.EHorizontalAlignment.HAlign_Center)
      self:ShowUWidget(self.Button_IgnoreAll)
    else
      self.HorizontalBox_Timer.Slot:SetHorizontalAlignment(UE4.EHorizontalAlignment.HAlign_Left)
      self:HideUWidget(self.Button_IgnoreAll)
    end
  end
end
function TeamApplyPage:SetTitle(inviteType)
  if self.Tex_Title then
    local titleText = ""
    if inviteType then
      titleText = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "PlayerInviteText")
    else
      titleText = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "EntryTeamApply")
    end
    self.Tex_Title:SetText(titleText)
  end
end
function TeamApplyPage:SetArrowDirection(inviteType)
  if inviteType then
    self.Img_Arrow:SetRenderTransformAngle(0)
  else
    self.Img_Arrow:SetRenderTransformAngle(180)
  end
end
function TeamApplyPage:SetRoomType(playerInfoData)
  if self.WidgetSwitcher_Type then
    if playerInfoData.InviteType then
      self.WidgetSwitcher_Type:SetActiveWidgetIndex(1)
      if self.Tex_RoomType then
        local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "RoomMode_" .. playerInfoData.RoomMode)
        self.Tex_RoomType:SetText(text)
      end
    else
      self.WidgetSwitcher_Type:SetActiveWidgetIndex(0)
    end
  end
end
function TeamApplyPage:AddPlayerItem(applyInfoData)
  local value = self.WBP_ApplyPlayerItemList:AddPlayerItem(applyInfoData)
  if value then
    value:SetPlayerHeadIcon(applyInfoData.PlayerIcon)
    value:UpdatePlayerInfo(applyInfoData)
  end
  self:RefreshButton()
  return value
end
function TeamApplyPage:OnItemRemove(item)
  item:StopRemoveTimer()
  TeamApplyAndInviteProxy:RemoveApplyStack(item:GetPlayerInfo().DataIndex)
  self:RemoveEntryItem(item)
  if self.currentSelectItem == item then
    self.currentSelectItem:SetSelectState(false)
    self.currentSelectItem = nil
    if 0 == self:GetEntryNum() then
      ViewMgr:ClosePage(self)
    else
      self:SetDefaultSelectItem()
    end
  elseif 0 == self:GetEntryNum() then
    ViewMgr:ClosePage(self)
  end
end
function TeamApplyPage:SetSelectPlayerByIndex(index)
  self.WBP_ApplyPlayerItemList:SetSelectedByIndex(index)
end
function TeamApplyPage:OnSelectPlayer(item)
  TeamApplyAndInviteBasePage.OnSelectPlayer(self, item)
  self.WBP_ApplyPlayerItemList:OnSelectPlayer(item)
end
function TeamApplyPage:RemoveEntryItem(item)
  self.WBP_ApplyPlayerItemList:RemovePlayerItem(item)
  self:RefreshButton()
end
function TeamApplyPage:GetAllEntries()
  return self.WBP_ApplyPlayerItemList.itemArr
end
function TeamApplyPage:GetEntryNum()
  return #self.WBP_ApplyPlayerItemList.itemArr
end
function TeamApplyPage:StopRemoveTimer()
  local itemArr = self.WBP_ApplyPlayerItemList.itemArr
  for i, item in ipairs(itemArr) do
    item:StopRemoveTimer()
  end
end
function TeamApplyPage:UpdateEntryItemInfo(applyInfoDataArry)
  local itemArr = self.WBP_ApplyPlayerItemList.itemArr
  for i, item in ipairs(itemArr) do
    local value = applyInfoDataArry[i]
    if item and value then
      item:SetPlayerHeadIcon(value.PlayerIcon)
      item:UpdatePlayerInfo(value)
    end
  end
end
return TeamApplyPage
