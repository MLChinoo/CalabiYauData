local GameModeSelectMediator = require("Business/Lobby/Mediators/GameModeSelectMediator")
local GameModeSelectPage = class("GameModeSelectPage", PureMVC.ViewComponentPage)
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
function GameModeSelectPage:ListNeededMediators()
  return {GameModeSelectMediator}
end
function GameModeSelectPage:InitializeLuaEvent()
  self.actionLuaHandleKeyEvent = LuaEvent.new()
  self.actionOnShow = LuaEvent.new()
end
function GameModeSelectPage:Construct()
  GameModeSelectPage.super.Construct(self)
  self:SetModeBtnVisibility()
  local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  roomDataProxy:SetRoomNetCheckTime(self.bp_netCheckTime)
end
function GameModeSelectPage:Destruct()
  GameModeSelectPage.super.Destruct(self)
end
function GameModeSelectPage:OnShow(luaData, originOpenData)
  self.actionOnShow()
end
function GameModeSelectPage:LuaHandleKeyEvent(key, inputEvent)
  self.actionLuaHandleKeyEvent(key, inputEvent)
  return false
end
function GameModeSelectPage:SetModeBtnVisibility()
  local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local modeDatas = roomDataProxy:GetModeDatas()
  if modeDatas then
    local bHasValidModeBtnOpen = false
    local bHasCustomRoomModeBtn = false
    for k, value in pairs(modeDatas) do
      if value.play_mode == RoomEnum.MapType.TeamSports then
        local teamSportsBtn = self.WBP_GameModeSelectPage_Btn_2
        if value.match_open then
          self:ShowModeBtn(teamSportsBtn, value)
          bHasValidModeBtnOpen = true
        else
          self:HiddenModeBtn(teamSportsBtn)
        end
      elseif value.play_mode == RoomEnum.MapType.BlastInvasion then
        local generalBlastingBtn = self.WBP_GameModeSelectPage_Btn_0
        if value.match_open then
          self:ShowModeBtn(generalBlastingBtn, value)
          bHasValidModeBtnOpen = true
        else
          self:HiddenModeBtn(generalBlastingBtn)
        end
        local rankBlastingBtn = self.WBP_GameModeSelectPage_Btn_1
        if value.rank_open then
          self:ShowModeBtn(rankBlastingBtn, value)
          bHasValidModeBtnOpen = true
        else
          self:HiddenModeBtn(rankBlastingBtn)
        end
      elseif value.play_mode == RoomEnum.MapType.CrystalWar then
        local crystalWarBtn = self.WBP_GameModeSelectPage_Btn_3
        if value.match_open then
          self:ShowModeBtn(crystalWarBtn, value)
          bHasValidModeBtnOpen = true
        else
          self:HiddenModeBtn(crystalWarBtn)
        end
      elseif value.play_mode == RoomEnum.MapType.Team5V5V5 then
        local team5V5V5Btn = self.WBP_GameModeSelectPage_Btn_5
        if value.match_open then
          self:ShowModeBtn(team5V5V5Btn, value)
          bHasValidModeBtnOpen = true
        else
          self:HiddenModeBtn(team5V5V5Btn)
        end
      end
      if value.contest_open and not bHasCustomRoomModeBtn then
        bHasCustomRoomModeBtn = true
      end
    end
    local customRoomBtn = self.WBP_GameModeSelectPage_Btn_4
    if bHasCustomRoomModeBtn then
      if customRoomBtn:GetVisibility() == UE4.ESlateVisibility.Collapsed then
        customRoomBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    else
      customRoomBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if not bHasValidModeBtnOpen and not bHasCustomRoomModeBtn then
      local modeDatasIsNotValid = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "ModeDatasIsNotValid")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, modeDatasIsNotValid)
    end
  else
    LogInfo("SetModeBtnVisibility", "modeDatas is nil")
  end
end
function GameModeSelectPage:ShowModeBtn(modeBtnWidget, modeData)
  if modeBtnWidget then
    modeBtnWidget:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if modeData then
      if modeData.time_limit then
        modeBtnWidget:SetModeDatas(modeData)
      end
    else
      LogInfo("ShowModeBtn", "modeData is nil")
    end
  else
    LogInfo("ShowModeBtn", "modeBtnWidget is invalid")
  end
end
function GameModeSelectPage:HiddenModeBtn(modeBtnWidget)
  if modeBtnWidget then
    modeBtnWidget:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    LogInfo("ShowModeBtn", "modeBtnWidget is invalid")
  end
end
function GameModeSelectPage:OnNavBarBtnClicked(remindMessage)
  if "" == remindMessage then
    if self.UI_RoomLimitTimeUMG then
      self.UI_RoomLimitTimeUMG:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  elseif self.UI_RoomLimitTimeUMG then
    self.UI_RoomLimitTimeUMG:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Txt_LimitTextContent:SetText(remindMessage)
  end
end
return GameModeSelectPage
