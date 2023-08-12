local FriendPanelMediatorMobile = require("Business/Friend/Mediators/Mobile/FriendSidePullItemPanelMobileMediator")
local FriendSidePullItemPanelMobile = class("FriendSidePullItemPanelMobile", PureMVC.ViewComponentPanel)
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
local roomDataProxy
function FriendSidePullItemPanelMobile:OnInitialized()
  FriendSidePullItemPanelMobile.super.OnInitialized(self)
end
function FriendSidePullItemPanelMobile:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function FriendSidePullItemPanelMobile:ListNeededMediators()
  return {FriendPanelMediatorMobile}
end
function FriendSidePullItemPanelMobile:InitializeLuaEvent()
  self.actionOnListItemObjectSet = LuaEvent.new()
end
function FriendSidePullItemPanelMobile:Construct()
  FriendSidePullItemPanelMobile.super.Construct(self)
  self.Btn_invite.OnClicked:Add(self, self.OnClickBtnInvite)
  roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  self.panelData = nil
end
function FriendSidePullItemPanelMobile:Destruct()
  FriendSidePullItemPanelMobile.super.Destruct(self)
  self.Btn_invite.OnClicked:Remove(self, self.OnClickBtnInvite)
end
function FriendSidePullItemPanelMobile:OnClickBtnInvite()
  if self.panelData then
    local roomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
    if roomProxy then
      local teamInfo = roomProxy:GetTeamInfo()
      local inviteFriendInfo = {}
      if teamInfo and teamInfo.teamId then
        inviteFriendInfo.teamId = teamInfo.teamId
      end
      inviteFriendInfo.level = self.panelData.level
      inviteFriendInfo.playerId = self.panelData.playerId
      GameFacade:SendNotification(NotificationDefines.InviteFriendCmd, self.panelData.playerId)
      GameFacade:SendNotification(NotificationDefines.InviteFriendCountdownCmd, self.panelData.playerId)
      self.WS_operateState:SetActiveWidgetIndex(1)
    end
  end
end
function FriendSidePullItemPanelMobile:ShowPanelInfo()
  if self.panelData then
    local data = self.panelData
    if data.nick and self.Txt_playerNick then
      self.Txt_playerNick:SetText(tostring(data.nick))
    end
    if self.Img_PlayerIcon then
      local avatarIcon = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetIconTexture(data.icon)
      if avatarIcon then
        self:SetImageByTexture2D(self.Img_PlayerIcon, avatarIcon)
      else
        LogError("FriendSidePullItemPanelMobile", "Player icon or config error")
      end
    end
    if data.stars then
      local CareerRankDataProxy = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy)
      local starShow, divisionCfg = CareerRankDataProxy:GetDivision(data.stars)
      if self.Txt_playerRankLevelName then
        self.Txt_playerRankLevelName:SetText(divisionCfg.Name)
      end
    end
    if self.Image_Division and self.Image_DivisionLevel then
      local _, divisionCfg = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivision(self.panelData.stars)
      self:SetImageByPaperSprite(self.Image_Division, divisionCfg.IconDivisionS)
      local pathString = UE4.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(divisionCfg.IconDivisionLevelS)
      if "" ~= pathString then
        self:SetImageByPaperSprite(self.Image_DivisionLevel, divisionCfg.IconDivisionLevelS)
        self.Image_DivisionLevel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        self.Image_DivisionLevel:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    self:UpdatePlayerStatus(self.panelData)
  end
end
function FriendSidePullItemPanelMobile:UpdatePlayerStatus(info)
  if info then
    if info.onlineStatus == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_ONLINE then
      self.WS_PlayerState:SetActiveWidgetIndex(FriendEnum.FriendStateType.Online)
      local bInTeam = false
      if self.panelData.teamId and 0 ~= self.panelData.teamId or self.panelData.roomId and 0 ~= self.panelData.roomId then
        bInTeam = true
      end
      self.WS_operateState:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if bInTeam and self.panelData.roomStatus ~= FriendEnum.RoomStatus.Running then
        local teamInfo = roomDataProxy:GetTeamInfo()
        if teamInfo and self.panelData.teamId and 0 ~= self.panelData.teamId and teamInfo.teamId and self.panelData.teamId == teamInfo.teamId then
          self.WS_operateState:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
        self.WS_PlayerState:SetActiveWidgetIndex(FriendEnum.FriendStateType.Room)
      elseif self.panelData.roomStatus == FriendEnum.RoomStatus.Running then
        self.WS_PlayerState:SetActiveWidgetIndex(FriendEnum.FriendStateType.Contest)
        self.WS_operateState:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      if not info.bInvite then
        self.WS_operateState:SetActiveWidgetIndex(1)
      else
        self.WS_operateState:SetActiveWidgetIndex(0)
      end
    else
      self.WS_operateState:SetVisibility(UE4.ESlateVisibility.Collapsed)
      if info.onlineStatus == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_LOST then
        self.WS_PlayerState:SetActiveWidgetIndex(FriendEnum.FriendStateType.LostLine)
      elseif info.onlineStatus == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_OFFLINE then
        self.WS_PlayerState:SetActiveWidgetIndex(FriendEnum.FriendStateType.OffOnline)
      elseif info.onlineStatus == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_LEAVE then
        self.WS_PlayerState:SetActiveWidgetIndex(FriendEnum.FriendStateType.Leave)
      elseif 3 == info.status then
        self.WS_PlayerState:SetActiveWidgetIndex(FriendEnum.FriendStateType.LostLine)
      end
    end
  end
end
function FriendSidePullItemPanelMobile:OnListItemObjectSet(listItemObject)
  self.panelData = listItemObject.data
  self:ShowPanelInfo()
end
return FriendSidePullItemPanelMobile
