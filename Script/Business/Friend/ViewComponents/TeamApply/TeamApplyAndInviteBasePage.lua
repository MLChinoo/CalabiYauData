local TeamApplyAndInviteBasePage = class("TeamApplyAndInviteBasePage", PureMVC.ViewComponentPage)
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
local GameModeSelectNum = require("Business/Lobby/Mediators/GameModeSelectEnum")
local TeamApplyAndInviteProxy, RoomProxy
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
function TeamApplyAndInviteBasePage:InitializeLuaEvent()
  TeamApplyAndInviteProxy = GameFacade:RetrieveProxy(ProxyNames.TeamApplyAndInviteProxy)
  RoomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  if self.Button_Accept then
    self.Button_Accept.OnClickEvent:Add(self, self.OnClickAccept)
  end
  if self.Button_Ignore then
    self.Button_Ignore.OnClickEvent:Add(self, self.OnClickIgnore)
  end
  if self.Button_IgnoreAll then
    self.Button_IgnoreAll.OnClickEvent:Add(self, self.OnClickIgnoreAll)
  end
  if self.CheckBox_Ignore then
    self.CheckBox_Ignore.OnCheckStateChanged:Add(self, self.OnCheckAutoIgnore)
  end
end
function TeamApplyAndInviteBasePage:Destruct()
  TeamApplyAndInviteBasePage.super.Destruct(self)
  if self.Button_Accept then
    self.Button_Accept.OnClickEvent:Remove(self, self.OnClickAccept)
  end
  if self.Button_Ignore then
    self.Button_Ignore.OnClickEvent:Remove(self, self.OnClickIgnore)
  end
  if self.Button_IgnoreAll then
    self.Button_IgnoreAll.OnClickEvent:Remove(self, self.OnClickIgnoreAll)
  end
  if self.CheckBox_Ignore then
    self.CheckBox_Ignore.OnCheckStateChanged:Remove(self, self.OnCheckAutoIgnore)
  end
end
function TeamApplyAndInviteBasePage:LuaHandleKeyEvent(key, inputEvent)
  return self.Button_Accept:MonitorKeyDown(key, inputEvent) or self.Button_Ignore:MonitorKeyDown(key, inputEvent)
end
function TeamApplyAndInviteBasePage:CheckCanFastClick()
  local bCanClick = false
  if self.clickTime == nil or nil == self.clickMillTime then
    bCanClick = true
    self.clickTime = os.time()
    self.clickMillTime = UE4.UKismetMathLibrary.GetMillisecond(UE4.UKismetMathLibrary.Now())
  else
    local curClickTime = os.time()
    local curClickMillTime = UE4.UKismetMathLibrary.GetMillisecond(UE4.UKismetMathLibrary.Now())
    if curClickTime - self.clickTime > 1 then
      bCanClick = true
      self.clickTime = curClickTime
      self.clickMillTime = curClickMillTime
    else
      if curClickMillTime < self.clickMillTime then
        curClickMillTime = curClickMillTime + 1000
      end
      if curClickMillTime - self.clickMillTime > 500 then
        self.clickTime = curClickTime
        if curClickMillTime >= 1000 then
          self.clickMillTime = curClickMillTime - 1000
        else
          self.clickMillTime = curClickMillTime
        end
        bCanClick = true
      end
    end
  end
  return bCanClick
end
function TeamApplyAndInviteBasePage:OnClickAccept()
  if not self:CheckCanFastClick() then
    return
  end
  if self.currentSelectItem then
    if self.currentSelectItem:GetPlayerInfo().InviteType then
      self:AcceptTeamInvite(self.currentSelectItem:GetPlayerInfo())
    else
      self:AcceptTeamApply()
    end
  end
  self:RemoveItem(self.currentSelectItem)
end
function TeamApplyAndInviteBasePage:OnClickIgnore()
  if not self:CheckCanFastClick() then
    return
  end
  if self.currentSelectItem then
    if self.currentSelectItem:GetPlayerInfo().InviteType then
      if 0 ~= self.ignorePlayerID then
        TeamApplyAndInviteProxy:StartAutoRefuseInvite(self.ignorePlayerID)
      end
    elseif 0 ~= self.ignorePlayerID then
      TeamApplyAndInviteProxy:StartAutoRefuseApply(self.ignorePlayerID)
    end
  end
  self:RemoveItem(self.currentSelectItem)
end
function TeamApplyAndInviteBasePage:OnClickIgnoreAll()
  if not self:CheckCanFastClick() then
    return
  end
  local itemArr = self:GetAllEntries()
  if itemArr then
    for i, item in ipairs(itemArr) do
      if item and item.bIgnore then
        if item:GetPlayerInfo().InviteType then
          TeamApplyAndInviteProxy:StartAutoRefuseApply(item:GetPlayerInfo().PlayerID)
        else
          TeamApplyAndInviteProxy:StartAutoRefuseInvite(item:GetPlayerInfo().PlayerID)
        end
      end
    end
  end
  ViewMgr:ClosePage(self)
end
function TeamApplyAndInviteBasePage:AddPlayerItem(applyInfoData)
end
function TeamApplyAndInviteBasePage:OnItemRemove(item)
end
function TeamApplyAndInviteBasePage:OnSelectPlayer(item)
  if self.currentSelectItem then
    self.currentSelectItem:SetSelectState(false)
  end
  self.currentSelectItem = item
  self.currentSelectItem:SetSelectState(true)
  local itemData = self.currentSelectItem:GetPlayerInfo()
  if itemData then
    self.currentSelectID = itemData.PlayerID
    self:UpdatePanelInfo(itemData)
  end
  self:SetCheckBoxIgnore(self.currentSelectItem:GetIgnoreState())
end
function TeamApplyAndInviteBasePage:UpdateEntryItemInfo(applyInfoDataArry)
end
function TeamApplyAndInviteBasePage:SetSelectPlayerByIndex(idnex)
end
function TeamApplyAndInviteBasePage:RemoveEntryItem(item)
end
function TeamApplyAndInviteBasePage:GetEntryNum()
end
function TeamApplyAndInviteBasePage:GetAllEntries()
end
function TeamApplyAndInviteBasePage:SetProgressBar(progress)
  if self.Button_Ignore then
    self.Button_Ignore:SetTimerIsShow(true)
    self.Button_Ignore:SetTime(progress)
  end
end
function TeamApplyAndInviteBasePage:StopRemoveTimer()
end
function TeamApplyAndInviteBasePage:SetCheckBoxIgnore(bCheck)
end
function TeamApplyAndInviteBasePage:OnClose()
  TeamApplyAndInviteBasePage.super.OnClose(self)
  self:StopRemoveTimer()
  TeamApplyAndInviteProxy:ClearAllTeamApply()
end
function TeamApplyAndInviteBasePage:RemoveItem(item)
  if item then
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
end
function TeamApplyAndInviteBasePage:SetDefaultSelectItem()
  if self.currentSelectItem then
    return
  end
  self:SetSelectPlayerByIndex(1)
end
function TeamApplyAndInviteBasePage:UpdatePlayerApplyList(applyInfoData)
  local item = self:AddPlayerItem(applyInfoData)
  item:SetCountDownFunc(function(progress)
    self:SetProgressBar(progress)
  end)
  item:SetButtonUpFunc(function(del)
    GameFacade:SendNotification(NotificationDefines.TeamApply.ItemClickNtf, del)
  end)
  self:SetDefaultSelectItem()
end
function TeamApplyAndInviteBasePage:AcceptTeamInvite(playerInfo)
  if playerInfo.InviteType == RoomEnum.InviteType.Room then
    TeamApplyAndInviteProxy:ReqRoomReply(playerInfo.RoomID, playerInfo.PlayerID, playerInfo.Pos, RoomEnum.AcceptInviteType.Accept)
  elseif playerInfo.InviteType == RoomEnum.InviteType.Team then
    TeamApplyAndInviteProxy:ReqTeamReply(playerInfo.TeamId, playerInfo.PlayerID, RoomEnum.AcceptInviteType.Accept)
  end
end
function TeamApplyAndInviteBasePage:AcceptTeamApply()
  local tempTeamInfo = RoomProxy:GetTeamInfo()
  local teamFullSize = 5
  if tempTeamInfo and tempTeamInfo.members then
    if tempTeamInfo.mode and tempTeamInfo.mode == GameModeSelectNum.GameModeType.Room then
      teamFullSize = 12
      if tempTeamInfo.mapID then
        local roomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
        local mapPlayMode = roomProxy:GetMapType(tempTeamInfo.mapID)
        if mapPlayMode == RoomEnum.MapType.Team5V5V5 then
          teamFullSize = 15
        end
      end
    end
    local robotNum = 0
    for key, value in pairs(tempTeamInfo.members) do
      if value.bIsRobot then
        robotNum = robotNum + 1
      end
    end
    local roomRealMemberNum = table.count(tempTeamInfo.members) - robotNum
    if roomRealMemberNum == teamFullSize then
      local commonText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "TeamFull")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, commonText)
    else
      RoomProxy:ReqQuitMatch()
      TeamApplyAndInviteProxy:ReqTeamApplyReply(tempTeamInfo.teamId, self.currentSelectID, FriendEnum.AcceptInviteType.Accept)
    end
  end
end
function TeamApplyAndInviteBasePage:OnCheckAutoIgnore(bCheck)
  if bCheck then
    self.ignorePlayerID = self.currentSelectID
    if self.currentSelectItem then
      self.currentSelectItem:SetIgnoreState(true)
    end
  else
    self.ignorePlayerID = 0
    if self.currentSelectItem then
      self.currentSelectItem:SetIgnoreState(false)
    end
  end
end
return TeamApplyAndInviteBasePage
