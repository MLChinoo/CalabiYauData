local FriendInfoPanelMediatorMobile = class("FriendInfoPanelMediatorMobile", PureMVC.Mediator)
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
local firendListDataProxy
function FriendInfoPanelMediatorMobile:ListNotificationInterests()
  return {}
end
function FriendInfoPanelMediatorMobile:HandleNotification(notify)
end
function FriendInfoPanelMediatorMobile:OnRegister()
  firendListDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  self:GetViewComponent().actionOnClickPlayerInfo:Add(self.OnClickPlayerInfo, self)
  self:GetViewComponent().actionOnClickBlack:Add(self.OnClickBlack, self)
  self:GetViewComponent().actionOnClickDelete:Add(self.OnClickDelete, self)
  self:GetViewComponent().actionOnClickComment:Add(self.OnClickComment, self)
  self.panelData = self:GetViewComponent().FriendPanelData.data
  self.currentSelect = self:GetViewComponent().FriendPanelData.currentSelect
  self:OnInitInfoPanel()
end
function FriendInfoPanelMediatorMobile:OnRemove()
  self:GetViewComponent().actionOnClickPlayerInfo:Remove(self.OnClickPlayerInfo, self)
  self:GetViewComponent().actionOnClickBlack:Remove(self.OnClickBlack, self)
  self:GetViewComponent().actionOnClickDelete:Remove(self.OnClickDelete, self)
  self:GetViewComponent().actionOnClickComment:Remove(self.OnClickComment, self)
end
function FriendInfoPanelMediatorMobile:OnInitInfoPanel()
  if self.panelData then
    if self:GetViewComponent().PlayeName_1 then
      local nick = ""
      if FunctionUtil:getByteCount(self.panelData.nick) > 9 then
        nick = FunctionUtil:getSubStringByCount(self.panelData.nick, 1, 8) .. "..."
      else
        nick = self.panelData.nick
      end
      self:GetViewComponent().PlayeName_1:SetText(nick)
    end
    if self:GetViewComponent().remarkText_1 then
      if "" ~= self.panelData.remarks and self.panelData.remarks ~= nil then
        self:GetViewComponent().remarkText_1:SetText(self.panelData.remarks)
      else
        local notRemarkText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "NotRemarkText")
        self:GetViewComponent().remarkText_1:SetText(notRemarkText)
      end
    end
    if self:GetViewComponent().SexIconMan and self:GetViewComponent().SexIconWoman then
      if 0 == self.panelData.sex then
        self:GetViewComponent().SexIconMan:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self:GetViewComponent().SexIconWoman:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        self:GetViewComponent().SexIconWoman:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self:GetViewComponent().SexIconMan:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    local division = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivisionConfigRow(self.panelData.rank)
    if division then
      if self:GetViewComponent().SegmentName_1 then
        self:GetViewComponent().SegmentName_1:SetText(division.Name)
      end
      if self:GetViewComponent().Image_Division and self:GetViewComponent().Image_DivisionLevel then
        self:GetViewComponent():SetImageByPaperSprite(self:GetViewComponent().Image_Division, division.IconDivisions)
        local pathString = UE4.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(division.IconDivisionLevelS)
        if "" ~= pathString then
          self:GetViewComponent():SetImageByPaperSprite(self:GetViewComponent().Image_DivisionLevel, division.IconDivisionLevelS)
          self:GetViewComponent().Image_DivisionLevel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        else
          self:GetViewComponent().Image_DivisionLevel:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
    end
    if self:GetViewComponent().HeadIcon_1 then
      if nil ~= firendListDataProxy.PlatformFriendList[self.panelData.playerId] then
        local picture_url = firendListDataProxy.PlatformFriendList[self.panelData.playerId].picture_url
        if picture_url then
          print("DownloadImage HeadIcon_1", picture_url)
          local dataCenter = UE4.UPMLoginDataCenter.Get(LuaGetWorld())
          local DownLoadTask
          if dataCenter:GetLoginType() == UE4.ELoginType.ELT_QQ then
            DownLoadTask = UE4.UAsyncTaskDownloadImage.DownloadImage(picture_url .. "100")
          elseif dataCenter:GetLoginType() == UE4.ELoginType.ELT_Wechat then
            DownLoadTask = UE4.UAsyncTaskDownloadImage.DownloadImage(picture_url .. "132")
          else
            self:LoadImgError()
          end
          if DownLoadTask then
            DownLoadTask.OnSuccess:Add(self:GetViewComponent(), self.LoadImgSuc)
            DownLoadTask.OnFail:Add(self:GetViewComponent(), self.LoadImgError)
          end
        end
      else
        local avatarId = tonumber(self.panelData.icon)
        if nil == avatarId then
          avatarId = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy):GetAvatarId()
        end
        if avatarId then
          local avatarIcon = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetIconTexture(avatarId)
          if avatarIcon then
            self:GetViewComponent().HeadIcon_1:SetBrushFromSoftTexture(avatarIcon)
            self:GetViewComponent().HeadIcon_1:SetVisibility(UE4.ESlateVisibility.Visible)
          else
            LogError("FriendPanelMediatorMobile", "Player icon or config error")
          end
        end
      end
    end
  end
  if self.currentSelect == FriendEnum.SelectCheckStatus.GameFriend then
  else
    if self.currentSelect == FriendEnum.SelectCheckStatus.ShieldedFriend then
    else
      self:GetViewComponent().RemarksBtn_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self:GetViewComponent().DeletePlayerBtn_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:GetViewComponent().ShieldPlayerBtn_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function FriendInfoPanelMediatorMobile:LoadImgSuc(InTexture)
  self.HeadIcon_1:SetBrushFromTextureDynamic(InTexture)
  self.HeadIcon_1:SetVisibility(UE4.ESlateVisibility.Visible)
end
function FriendInfoPanelMediatorMobile:LoadImgError()
  local avatarId = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy):GetAvatarId()
  if avatarId then
    local avatarIcon = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetIconTexture(avatarId)
    if avatarIcon then
      self.HeadIcon_1:SetBrushFromSoftTexture(avatarIcon)
      self.HeadIcon_1:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      LogError("FriendInfoPanelMediatorMobile", "Player icon or config error")
    end
  end
end
function FriendInfoPanelMediatorMobile:OnClickPlayerInfo()
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.FriendProfilePage, false, self.panelData.playerId)
  self:GetViewComponent().Root:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function FriendInfoPanelMediatorMobile:OnClickBlack()
  if self.panelData then
    local blackFriendData = {}
    blackFriendData.playerId = self.panelData.playerId
    blackFriendData.nick = self.panelData.nick
    GameFacade:SendNotification(NotificationDefines.ShieldFriendCmd, blackFriendData)
    self:GetViewComponent().Root:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function FriendInfoPanelMediatorMobile:OnClickDelete()
  if self.panelData then
    local deleteInfo = {}
    deleteInfo.playerId = self.panelData.playerId
    deleteInfo.friendType = self.panelData.friendType
    deleteInfo.nick = self.panelData.nick
    GameFacade:SendNotification(NotificationDefines.DeleteFriendCmd, deleteInfo)
    self:GetViewComponent().Root:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function FriendInfoPanelMediatorMobile:OnClickComment()
  local sendData = {}
  sendData.playerId = self.panelData.playerId
  ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.FriendRemark)
  GameFacade:SendNotification(NotificationDefines.FriendCmdType.SetRemarkUserInfo, sendData)
  self:GetViewComponent().Root:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
return FriendInfoPanelMediatorMobile
