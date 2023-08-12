local GameModeSelectPageNavBarBtnMobile = class("GameModeSelectPageNavBarBtnMobile", PureMVC.ViewComponentPanel)
local GameModeSelectNum = require("Business/Lobby/Mediators/GameModeSelectEnum")
function GameModeSelectPageNavBarBtnMobile:Construct()
  GameModeSelectPageNavBarBtnMobile.super.Construct(self)
  if self.CheckBox_Left and self.CheckBox_Middle and self.CheckBox_Right then
    self.CheckBox_Left.OnCheckStateChanged:Add(self, GameModeSelectPageNavBarBtnMobile.OnCheckStateChanged)
    self.CheckBox_Middle.OnCheckStateChanged:Add(self, GameModeSelectPageNavBarBtnMobile.OnCheckStateChanged)
    self.CheckBox_Right.OnCheckStateChanged:Add(self, GameModeSelectPageNavBarBtnMobile.OnCheckStateChanged)
  end
  self.bIsChecked = false
  self:InitInfo()
end
function GameModeSelectPageNavBarBtnMobile:Destruct()
  GameModeSelectPageNavBarBtnMobile.super.Destruct(self)
  if self.CheckBox_Left and self.CheckBox_Middle and self.CheckBox_Right then
    self.CheckBox_Left.OnCheckStateChanged:Remove(self, GameModeSelectPageNavBarBtnMobile.OnCheckStateChanged)
    self.CheckBox_Middle.OnCheckStateChanged:Remove(self, GameModeSelectPageNavBarBtnMobile.OnCheckStateChanged)
    self.CheckBox_Right.OnCheckStateChanged:Remove(self, GameModeSelectPageNavBarBtnMobile.OnCheckStateChanged)
  end
end
function GameModeSelectPageNavBarBtnMobile:InitInfo()
  if self.TextBlock_Template then
    self.TextBlock_Template:SetText(self.bp_btnText)
  end
  if self.WS_Style then
    self.WS_Style:SetActiveWidgetIndex(self.bp_btnType)
  end
  if self.bp_unSelectBtnIconTexture then
    self:SetImageByPaperSprite(self.Img_NormalIcon, self.bp_unSelectBtnIconTexture)
  end
  if self.bp_selectBtnIconTexture then
    self:SetImageByPaperSprite(self.Img_SelectIcon, self.bp_selectBtnIconTexture)
  end
end
function GameModeSelectPageNavBarBtnMobile:OnCheckStateChanged(bIsChecked)
  self:SetBtnStyle(false)
  local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local teamInfo = roomDataProxy:GetTeamInfo()
  if not teamInfo or not teamInfo.teamId then
    LogInfo("GameModeSelectPageNavBarBtn:", "teamInfo is InValid")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TeamInfoInValid"))
    GameFacade:SendNotification(NotificationDefines.GameModeSelect, true, NotificationDefines.GameModeSelect.QuitRoomByEsc)
    return
  end
  if not roomDataProxy:IsTeamLeader() and not self.bIsChecked then
    GameFacade:SendNotification(NotificationDefines.GameModeSelect.RestoreGameMode)
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "NonOwnerCantSelectmode"))
    return
  elseif roomDataProxy:GetIsInMatch() and not self.bIsChecked then
    GameFacade:SendNotification(NotificationDefines.GameModeSelect.RestoreGameMode)
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "MatchingCantSwitchMode"))
    return
  elseif roomDataProxy:GetTeamMemberCount() > 5 and roomDataProxy:GetGameModeType() == GameModeSelectNum.GameModeType.Room then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "CantSwitchModesForLimitPeople"))
    return
  end
  if bIsChecked then
    if self.bIsChecked ~= bIsChecked then
      self.bIsChecked = bIsChecked
      GameFacade:SendNotification(NotificationDefines.GameModeSelect.ClickGameModeSelectNavBtn, self.bp_btnIndex)
    end
  else
    local checkbox = self.WS_Style:GetWidgetAtIndex(self.bp_btnType)
    if checkbox then
      checkbox:SetIsChecked(true)
    end
  end
end
function GameModeSelectPageNavBarBtnMobile:SetBtnStyle(bIsChecked)
  self.bIsChecked = bIsChecked
  GameFacade:SendNotification(NotificationDefines.GameModeSelect.ClearAllGameModeSelectNavBtn)
  local checkbox = self.WS_Style:GetWidgetAtIndex(self.bp_btnType)
  if checkbox then
    checkbox:SetIsChecked(bIsChecked)
    if bIsChecked then
      local audio = UE4.UPMLuaAudioBlueprintLibrary
      audio.PostEvent(audio.GetID(self.bp_clickSound))
      self.WS_BoomModeImage:SetActiveWidgetIndex(1)
      self.TextBlock_Template:SetColorAndOpacity(self.bp_selectBtnTextSlateColor)
    end
  end
end
function GameModeSelectPageNavBarBtnMobile:OnClearBtnStyle()
  self.bIsChecked = false
  local checkbox = self.WS_Style:GetWidgetAtIndex(self.bp_btnType)
  if checkbox then
    checkbox:SetIsChecked(self.bIsChecked)
    self.WS_BoomModeImage:SetActiveWidgetIndex(0)
    self.TextBlock_Template:SetColorAndOpacity(self.bp_unSelectBtnTextSlateColor)
  end
end
return GameModeSelectPageNavBarBtnMobile
