local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
local SettingCombatItemMediator = require("Business/Setting/Mediators/SettingCombatItemMediator")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local SettingCombatItem = class("SettingCombatItem", PureMVC.ViewComponentPanel)
local CardEnum = require("Business/Room/Mediators/Card/CardEnum")
local InteractAct = {
  Signal = 1,
  WordChat = 2,
  Voice = 3,
  Friend = 4,
  Team = 5,
  Tipoff = 6
}
function SettingCombatItem:ListNeededMediators()
  return {SettingCombatItemMediator}
end
function SettingCombatItem:InitializeLuaEvent()
  self.CheckBox_Signal.OnCheckStateChanged:Add(self, self.OnSignalCheck)
  self.CheckBox_WordChat.OnCheckStateChanged:Add(self, self.OnWordChatCheck)
  self.CheckBox_Voice.OnCheckStateChanged:Add(self, self.OnVoiceCheck)
  self.Slider_Voice.OnValueChanged:Add(self, self.OnVoiceValueChanged)
  self.Button_AddFriend.OnClicked:Add(self, self.OnAddFriendClick)
  self.Button_InviteTeam.OnClicked:Add(self, self.OnInviteTeamClick)
  self.Button_Tipoff.OnClicked:Add(self, self.OnTipOffClick)
  self.minVoiceValue, self.maxVoiceValue = 0, 100
  self.Slider_Voice:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Button_InviteTeam:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function SettingCombatItem:SetItemData(data)
  self:SetFreeStatus(false)
  self._data = data
  self.currentVoiceValue = self:GetValueByAct(InteractAct.Voice)
  self:RefreshView()
end
function SettingCombatItem:RefreshView()
  if self._data.name then
    self.Text_Name:SetText(self._data.name)
  end
  if self._data.imageHead then
    self.Image_Head:SetBrushFromSoftTexture(self._data.imageHead)
  end
  self:RefreshTeamInvite()
  self:RefreshAddFriend()
  self:RefreshNameColor()
  self:RefreshSignalChecked()
  self:RefreshWordChatChecked()
  self:RefreshVoiceUI()
  self:RefreshTipoff()
end
function SettingCombatItem:OnSignalCheck(bIsChecked)
  LogInfo("SettingCombatItem", "OnSignalCheck" .. tostring(bIsChecked))
  self:SetValueByAct(InteractAct.Signal, bIsChecked)
end
function SettingCombatItem:OnWordChatCheck(bIsChecked)
  LogInfo("SettingCombatItem", "OnWordChatCheck" .. tostring(bIsChecked))
  if true == bIsChecked then
    GameFacade:SendNotification(NotificationDefines.Setting.SettingSwitchSingleEnemyChatNtf, {bChecked = false})
  end
  self:SetWordChatOpen(bIsChecked)
end
function SettingCombatItem:OnVoiceCheck(bIsChecked)
  LogInfo("SettingCombatItem", "OnVoiceCheck" .. tostring(bIsChecked))
  if bIsChecked then
    self.currentVoiceValue = self.maxVoiceValue
  else
    self.currentVoiceValue = self.minVoiceValue
  end
  self:RefreshVoiceSlider()
end
function SettingCombatItem:OnVoiceValueChanged(value)
  self.currentVoiceValue = self.minVoiceValue + math.floor((self.maxVoiceValue - self.minVoiceValue) * value)
  self:RefreshVoiceSlider()
end
function SettingCombatItem:OnAddFriendClick()
  LogInfo("SettingCombatItem", "OnAddFriendClick")
  self:SetValueByAct(InteractAct.Friend, true)
  self:RefreshAddFriend()
end
function SettingCombatItem:OnInviteTeamClick()
  self:SetValueByAct(InteractAct.Team, true)
  self:RefreshTeamInvite()
end
function SettingCombatItem:OnTipOffClick()
  self:SetValueByAct(InteractAct.Tipoff, true)
  self:RefreshTipoff()
end
function SettingCombatItem:RefreshNameColor()
  if self.isSelf then
    self.Text_Name:SetColorAndOpacity(self.SelfColor)
  else
    self.Text_Name:SetColorAndOpacity(self.OtherColor)
  end
end
function SettingCombatItem:CheckInATeam()
  return self._data.bInTeam
end
function SettingCombatItem:RefreshTeamInvite()
  local SettingCombatProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCombatProxy)
  if self._data.teamFlag == false then
    self.Button_InviteTeam:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif self._data.bIsSelf == true then
    self.Button_InviteTeam:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif SettingCombatProxy:CheckIsCustomRoomMode() then
    self.Button_InviteTeam:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif self._data.bInTeam then
    self.Text_Invite:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "10"))
    self.Button_InviteTeam:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Button_InviteTeam:SetIsEnabled(false)
  elseif self:GetValueByAct(InteractAct.Team) then
    self.Text_Invite:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "11"))
    self.Button_InviteTeam:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Button_InviteTeam:SetIsEnabled(false)
  else
    self.Text_Invite:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "12"))
    self.Button_InviteTeam:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Button_InviteTeam:SetIsEnabled(true)
  end
  self.Button_InviteTeam:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function SettingCombatItem:RefreshAddFriend()
  if self._data.bIsSelf == true then
    self.Button_AddFriend:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif true == self._data.teamFlag and self._data.bIsFriend == false then
    local friendInviteStatus = self:GetValueByAct(InteractAct.Friend)
    LogInfo("SettingCombatItem", "friendInviteStatus " .. tostring(friendInviteStatus))
    if friendInviteStatus then
      self.Text_AddFriend:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "13"))
      self.Button_AddFriend:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Text_AddFriend:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "14"))
      self.Button_AddFriend:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  else
    self.Button_AddFriend:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function SettingCombatItem:RefreshSignalChecked()
  if self._data.bIsSelf == true then
    self.Panel_Signal:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif self._data.teamFlag then
    local bChecked = self:GetValueByAct(InteractAct.Signal)
    self.CheckBox_Signal:SetIsChecked(bChecked)
    self.Panel_Signal:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Panel_Signal:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function SettingCombatItem:RefreshWordChatChecked()
  if self._data.bIsSelf then
    self.Panel_WordChat:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    local bWorldChatStatus = self:GetValueByAct(InteractAct.WordChat)
    self.CheckBox_WordChat:SetIsChecked(bWorldChatStatus)
  end
end
function SettingCombatItem:SetWordChatOpen(bOpen)
  if self._data == nil then
    return
  end
  self:SetValueByAct(InteractAct.WordChat, bOpen)
end
function SettingCombatItem:RefreshVoiceUI()
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  LogInfo("TeamChat's status", tostring(SettingSaveDataProxy:GetTemplateValueByKey("Switch_TeamChat")) .. "")
  if self._data.bIsSelf == true then
    self.Panel_Voice:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif self._data.teamFlag and SettingHelper.IsTeamChatOpen() then
    self.Panel_Voice:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CheckBox_Voice:SetIsChecked(self._data.bVoiceChecked)
    self:RefreshVoiceSlider()
  else
    self.Panel_Voice:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function SettingCombatItem:RefreshVoiceSlider()
  self.currentVoiceValue = math.clamp(self.currentVoiceValue, self.minVoiceValue, self.maxVoiceValue)
  local percent = (self.currentVoiceValue - self.minVoiceValue) / (self.maxVoiceValue - self.minVoiceValue)
  self.ProgressBar_Voice:SetPercent(percent)
  self.Slider_Voice:SetValue(percent)
  self:RefreshCheckItem()
  self:SetValueByAct(InteractAct.Voice, self.currentVoiceValue)
end
function SettingCombatItem:RefreshCheckItem()
  local voiceManager = UE4.UPMVoiceManager.Get(LuaGetWorld())
  if self.currentVoiceValue == self.minVoiceValue then
    if self.CheckBox_Voice:IsChecked() then
      self.CheckBox_Voice:SetIsChecked(false)
    end
  elseif self.CheckBox_Voice:IsChecked() == false then
    self.CheckBox_Voice:SetIsChecked(true)
  end
  if self.CheckBox_Voice:IsChecked() == false then
    voiceManager:SetPlayreForbidVoiceState(self._data.uid, true)
    voiceManager:SetPlayreForbidVoiceState(self._data.uid, true)
  else
    voiceManager:SetPlayreForbidVoiceState(self._data.uid, false)
    voiceManager:SetPlayreForbidVoiceState(self._data.uid, false)
  end
end
function SettingCombatItem:RefreshTipoff()
  local SettingCombatProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCombatProxy)
  local TipoffPlayerDataProxy = GameFacade:RetrieveProxy(ProxyNames.TipoffPlayerDataProxy)
  if TipoffPlayerDataProxy and self._data then
    if SettingCombatProxy and not SettingCombatProxy:IsRobotPlayer(self._data) then
      if self._data.bIsSelf then
        self.Button_Tipoff:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        self.Button_Tipoff:SetVisibility(UE4.ESlateVisibility.Visible)
        self.Text_Tipoff:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Tipoff, "Tipoff"))
      end
    else
      self.Button_Tipoff:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.Button_Tipoff:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function SettingCombatItem:SetFreeStatus(bFree)
  local Vis = bFree and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible
  self.Image_Head:SetVisibility(Vis)
  self.Panel_Voice:SetVisibility(Vis)
  self.Panel_Communicate:SetVisibility(Vis)
  self.Panel_Action:SetVisibility(Vis)
  if bFree then
    self.Text_Name:SetText("-")
  end
end
function SettingCombatItem:SetValueByAct(act, value)
  local SettingCombatProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCombatProxy)
  if act == InteractAct.Signal then
    SettingCombatProxy:SetSignalStatusByPlayerId(self._data.uid, value)
  elseif act == InteractAct.WordChat then
    SettingCombatProxy:SetWordChatStatusByPlayerId(self._data.uid, value)
    self.CheckBox_WordChat:SetIsChecked(value)
  elseif act == InteractAct.Voice then
    SettingCombatProxy:SetVoiceByPlayerId(self._data.uid, value)
    UE4.UPMVoiceManager.Get(LuaGetWorld()):SetPlayerVolume(self._data.uid .. "", math.floor(value))
  elseif act == InteractAct.Friend then
    if true == value then
      local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
      if friendDataProxy and SettingCombatProxy:IsRobotPlayer(self._data) == false then
        friendDataProxy:ReqFriendAdd(self._data.name, self._data.uid, FriendEnum.FriendType.Friend)
      end
      local text = ObjectUtil:GetTextFromFormat(ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "15"), {
        self._data.name
      })
      GameFacade:SendNotification(NotificationDefines.Chat.AddSystemMsg, text)
    end
    SettingCombatProxy:SetFriendInviteByPlayerId(self._data.uid, value)
  elseif act == InteractAct.Team then
    if true == value then
      if SettingCombatProxy:IsRobotPlayer(self._data) == false then
        SettingCombatProxy:AddTeamInviteId(self._data.uid)
      end
      local text = ObjectUtil:GetTextFromFormat(ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "16"), {
        self._data.name
      })
      GameFacade:SendNotification(NotificationDefines.Chat.AddSystemMsg, text)
    end
    SettingCombatProxy:SetTeamInviteStatusByPlayerId(self._data.uid, value)
  elseif act == InteractAct.Tipoff and value then
    local TipoffPageParam = {
      TargetUID = self._data.uid,
      EnteranceType = UE4.ECyTipoffEntranceType.ENTERANCE_INGAME,
      SceneType = UE4.ECyTipoffSceneType.IN_GAME
    }
    GameFacade:SendNotification(NotificationDefines.TipoffPlayer.OpenTipOffPlayerCmd, TipoffPageParam)
  end
end
function SettingCombatItem:GetValueByAct(act)
  local SettingCombatProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCombatProxy)
  if act == InteractAct.Signal then
    return SettingCombatProxy:GetSignalStatusByPlayerId(self._data.uid)
  elseif act == InteractAct.WordChat then
    return SettingCombatProxy:GetWordChatStatusByPlayerId(self._data.uid)
  elseif act == InteractAct.Voice then
    return SettingCombatProxy:GetVoiceByPlayerId(self._data.uid)
  elseif act == InteractAct.Friend then
    return SettingCombatProxy:GetFriendInviteByPlayerId(self._data.uid)
  elseif act == InteractAct.Team then
    return SettingCombatProxy:GetTeamInviteStatusByPlayerId(self._data.uid)
  end
end
function SettingCombatItem:SetV10()
  self.Panel_Voice:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Panel_Signal:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Panel_WordChat.Slot:SetPosition(UE4.FVector2D(-50.0, -14.0))
  self.Button_Tipoff.Slot:SetPosition(UE4.FVector2D(-25.0, 0))
end
return SettingCombatItem
