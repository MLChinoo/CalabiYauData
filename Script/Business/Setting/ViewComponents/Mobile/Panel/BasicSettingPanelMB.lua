local BasicSettingPanelMB = class("BasicSettingPanelMB", PureMVC.ViewComponentPanel)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local PanelTypeStr = SettingEnum.PanelTypeStr
function BasicSettingPanelMB:ListNeededMediators()
  return {}
end
function BasicSettingPanelMB:InitializeLuaEvent()
  local settingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local subTypeMap, titleTypeMap, allItemMap = settingConfigProxy:GetDataByPanelStr(PanelTypeStr.Basic)
  if 1 == #subTypeMap then
    local subTypeStr = subTypeMap[1]
    local args = {
      itemList = allItemMap[subTypeStr],
      titleList = titleTypeMap[subTypeStr]
    }
    local itemlistPanel = SettingHelper.CreateItemListPanel(args)
    self.SizeBox_ShowItem:AddChild(itemlistPanel)
  end
  self.Button_BackToLobby.OnClicked:Add(self, BasicSettingPanelMB.OnBackToLobbyClicked)
  self.Button_Surrender.OnClicked:Add(self, BasicSettingPanelMB.OnSurrenderClicked)
  self.Button_BackToLogin.OnClicked:Add(self, BasicSettingPanelMB.OnLogoutGame)
  local SettingCombatProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCombatProxy)
  local isInGame = SettingCombatProxy:CheckIsInGame()
  if isInGame then
    self.SizeBox_BackToLogin:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local CurrentGameState = UE4.UGameplayStatics.GetGameState(self)
    if SettingCombatProxy:CheckIsCustomRoomMode() or CurrentGameState.GetModeType and CurrentGameState:GetModeType() == UE4.EPMGameModeType.Practice then
      self.SizeBox_BackToLobby:SetVisibility(UE4.ESlateVisibility.Visible)
      if CurrentGameState.GetModeType and CurrentGameState:GetModeType() == UE4.EPMGameModeType.Practice then
        self.returnText:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "42"))
      end
    else
      self.SizeBox_BackToLobby:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if CurrentGameState:GetModeType() == UE4.EPMGameModeType.Bomb then
      self.SizeBox_Surrender:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.SizeBox_Surrender:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.SizeBox_BackToLogin:SetVisibility(UE4.ESlateVisibility.Visible)
    self.SizeBox_BackToLobby:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SizeBox_Surrender:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  TimerMgr:AddTimeTask(0.2, 0, 0, function()
    GameFacade:SendNotification(NotificationDefines.Setting.SetSettingDefaultButtonNtf, {
      btn = self.Button_Default
    })
  end)
end
function BasicSettingPanelMB:OnLogoutGame()
  local roomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local bInTeam = false
  if roomProxy then
    local cnt = roomProxy:GetTeamInfoMember()
    if cnt > 1 then
      bInTeam = true
    end
  end
  local pageData = {
    contentTxt = bInTeam and ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "39") or ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "38"),
    returnTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "43"),
    cb = function(bConfirm)
      if bConfirm then
        UE4.UPMWidgetBlueprintLibrary.LogoutGame(self)
      end
    end
  }
  ViewMgr:OpenPage(self, UIPageNameDefine.MsgDialogPage, false, pageData)
end
function BasicSettingPanelMB:OnBackToLobbyClicked()
  local GameState = UE4.UGameplayStatics.GetGameState(self)
  if not GameState then
    return
  end
  local pageData = {}
  if GameState:GetModeType() == UE4.EPMGameModeType.Practice then
    pageData.contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "PracticeBackToRoomTipsText")
    pageData.confirmTxt = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TipsConfirmText")
    pageData.returnTxt = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TipsCancelText")
  elseif GameState:GetModeType() < UE4.EPMGameModeType.NoviceGuide then
    pageData.contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "BackToLobbyTipsText")
    pageData.confirmTxt = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TipsConfirmText")
    pageData.returnTxt = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TipsCancelText")
  end
  pageData.source = self
  pageData.cb = BasicSettingPanelMB.OnBackToLobbyReturn
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.MsgDialogPage, false, pageData)
end
function BasicSettingPanelMB:OnBackToLobbyReturn(bFirstBtn)
  if bFirstBtn then
    local GameState = UE4.UGameplayStatics.GetGameState(self)
    if not GameState then
      return
    end
    if GameState:GetModeType() == UE4.EPMGameModeType.Practice then
      local RoomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
      RoomProxy:ReqTeamLeavePractice()
    elseif GameState:GetModeType() < UE4.EPMGameModeType.NoviceGuide then
      local SettingProxy = GameFacade:RetrieveProxy(ProxyNames.SettingProxy)
      SettingProxy:ReturnToLobby()
    end
  end
end
function BasicSettingPanelMB:OnSurrenderClicked()
  local CurrentGameState = UE4.UGameplayStatics.GetGameState(self)
  local tip = ""
  if CurrentGameState.Surrend then
    tip = CurrentGameState:Surrend()
  end
  if "" ~= tip then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tip)
  end
  self:CloseSelf()
end
function BasicSettingPanelMB:CloseSelf()
  ViewMgr:ClosePage(self, UIPageNameDefine.SettingPage)
end
return BasicSettingPanelMB
