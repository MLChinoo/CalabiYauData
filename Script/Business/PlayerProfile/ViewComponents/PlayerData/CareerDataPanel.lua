local CareerDataMediator = require("Business/PlayerProfile/Mediators/PlayerData/CareerDataMediator")
local CareerDataPanel = class("CareerDataPanel", PureMVC.ViewComponentPanel)
local GameModeEnum = require("Business/PlayerProfile/Proxies/GameModeEnumDefine")
function CareerDataPanel:ListNeededMediators()
  return {CareerDataMediator}
end
function CareerDataPanel:InitView()
  self:OnGameModeChange(ConfigMgr:FromStringTable(StringTablePath.ST_PlayerProfile, "GameModeRankBomb"))
end
function CareerDataPanel:UpdateView(infoShown)
  if self.TextBlock_JoinTime then
    local time = os.date("*t", infoShown.firstTime)
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_PlayerProfile, "JoinTimeFormat")
    local stringMap = {
      [0] = time.year % 100,
      [1] = time.month,
      [2] = time.day
    }
    local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    self.TextBlock_JoinTime:SetText(text)
  end
  if self.TextBlock_ThumbCount then
    self.TextBlock_ThumbCount:SetText(infoShown.praise)
  end
  if infoShown.battleInfo then
    if self.TextBlock_GameCount then
      self.TextBlock_GameCount:SetText(infoShown.battleInfo.round)
    end
    if self.TextBlock_WinRate then
      self.TextBlock_WinRate:SetText(string.format("%.1f", infoShown.battleInfo.win_rate * 100) .. "%")
    end
    if self.TextBlock_MvpRate then
      if self.selectedGameMode and self.selectedGameMode == Pb_ncmd_cs.ERoomMode.RoomMode_MINE then
        self.TextBlock_MvpRate:SetText(infoShown.battleInfo.mine_mvp)
      else
        self.TextBlock_MvpRate:SetText(string.format("%.1f", infoShown.battleInfo.mvp_rate * 100) .. "%")
      end
    end
    if self.TextBlock_AverageDamage then
      self.TextBlock_AverageDamage:SetText(string.format("%.1f", infoShown.battleInfo.ave_damage))
    end
    if self.TextBlock_AverageKill then
      if self.selectedGameMode and self.selectedGameMode == Pb_ncmd_cs.ERoomMode.RoomMode_MINE then
        self.TextBlock_AverageKill:SetText(infoShown.battleInfo.ave_crystal)
      else
        self.TextBlock_AverageKill:SetText(string.format("%.1f", infoShown.battleInfo.ave_kill))
      end
    end
    if self.TextBlock_HeadShotRate then
      if self.selectedGameMode and self.selectedGameMode == Pb_ncmd_cs.ERoomMode.RoomMode_MINE then
        self.TextBlock_HeadShotRate:SetText(infoShown.battleInfo.max_crystal)
      else
        self.TextBlock_HeadShotRate:SetText(string.format("%.1f", infoShown.battleInfo.head_burst_rate * 100) .. "%")
      end
    end
  else
    if self.TextBlock_GameCount then
      self.TextBlock_GameCount:SetText("0")
    end
    if self.TextBlock_WinRate then
      self.TextBlock_WinRate:SetText("0.0%")
    end
    if self.TextBlock_MvpRate then
      if self.selectedGameMode and self.selectedGameMode == Pb_ncmd_cs.ERoomMode.RoomMode_MINE then
        self.TextBlock_MvpRate:SetText("0")
      else
        self.TextBlock_MvpRate:SetText("0.0%")
      end
    end
    if self.TextBlock_AverageDamage then
      self.TextBlock_AverageDamage:SetText("0.0")
    end
    if self.TextBlock_AverageKill then
      if self.selectedGameMode and self.selectedGameMode == Pb_ncmd_cs.ERoomMode.RoomMode_MINE then
        self.TextBlock_AverageKill:SetText("0")
      else
        self.TextBlock_AverageKill:SetText("0.0")
      end
    end
    if self.TextBlock_HeadShotRate then
      if self.selectedGameMode and self.selectedGameMode == Pb_ncmd_cs.ERoomMode.RoomMode_MINE then
        self.TextBlock_HeadShotRate:SetText("0")
      else
        self.TextBlock_HeadShotRate:SetText("0.0%")
      end
    end
  end
end
function CareerDataPanel:Construct()
  CareerDataPanel.super.Construct(self)
  self.gameModeMap = {}
  if self.ComboBox_Career then
    local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
    for key, value in pairsByKeys(GameModeEnum.gameModeName) do
      local bIgnore = false
      if platform == GlobalEnumDefine.EPlatformType.Mobile and GameModeEnum.gameModeMap[value] == Pb_ncmd_cs.ERoomMode.RoomMode_TEAM_5V5V5 then
        bIgnore = true
      end
      if platform == GlobalEnumDefine.EPlatformType.PC and GameModeEnum.gameModeMap[value] == Pb_ncmd_cs.ERoomMode.RoomMode_TEAM_3V3V3 then
        bIgnore = true
      end
      if false == bIgnore then
        local gameText = ConfigMgr:FromStringTable(StringTablePath.ST_PlayerProfile, value)
        if key > 1 then
          self.ComboBox_Career:AddOption(gameText)
        end
        self.gameModeMap[gameText] = GameModeEnum.gameModeMap[value]
      end
    end
    self.selectedGameMode = Pb_ncmd_cs.ERoomMode.RoomMode_BOMB
    self.ComboBox_Career.OnSelectionChanged:Add(self, self.OnGameModeChange)
    self.ComboBox_Career.OnMenuOpenChanged:Add(self, self.OnMenuOpen)
  end
end
function CareerDataPanel:Destruct()
  if self.ComboBox_Career then
    self.ComboBox_Career.OnSelectionChanged:Remove(self, self.OnGameModeChange)
    self.ComboBox_Career.OnMenuOpenChanged:Remove(self, self.OnMenuOpen)
  end
  CareerDataPanel.super.Destruct(self)
end
function CareerDataPanel:OnGameModeChange(selectedItem, selectionType)
  self.selectedGameMode = self.gameModeMap[selectedItem]
  if self.selectedGameMode == Pb_ncmd_cs.ERoomMode.RoomMode_MINE then
    if self.WidgetSwitcher_MVP then
      self.WidgetSwitcher_MVP:SetActiveWidgetIndex(1)
    end
    if self.WidgetSwitcher_Kill then
      self.WidgetSwitcher_Kill:SetActiveWidgetIndex(1)
    end
    if self.WidgetSwitcher_Best then
      self.WidgetSwitcher_Best:SetActiveWidgetIndex(1)
    end
  else
    if self.WidgetSwitcher_MVP then
      self.WidgetSwitcher_MVP:SetActiveWidgetIndex(0)
    end
    if self.WidgetSwitcher_Kill then
      self.WidgetSwitcher_Kill:SetActiveWidgetIndex(0)
    end
    if self.WidgetSwitcher_Best then
      self.WidgetSwitcher_Best:SetActiveWidgetIndex(0)
    end
  end
  GameFacade:SendNotification(NotificationDefines.PlayerProfile.PlayerData.GetCareerDataCmd, self.selectedGameMode)
end
function CareerDataPanel:OnMenuOpen(isOpen)
  if self.Image_ArrowR then
    if isOpen then
      self.Image_ArrowR:SetRenderScale(UE4.FVector2D(1, 1))
    else
      self.Image_ArrowR:SetRenderScale(UE4.FVector2D(1, -1))
    end
  end
end
return CareerDataPanel
