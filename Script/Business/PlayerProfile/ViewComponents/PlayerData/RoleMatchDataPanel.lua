local RoleMatchDataMediator = require("Business/PlayerProfile/Mediators/PlayerData/RoleMatchDataMediator")
local RoleMatchDataPanel = class("RoleMatchDataPanel", PureMVC.ViewComponentPanel)
local GameModeEnum = require("Business/PlayerProfile/Proxies/GameModeEnumDefine")
function RoleMatchDataPanel:ListNeededMediators()
  return {RoleMatchDataMediator}
end
function RoleMatchDataPanel:InitView()
  self:OnGameModeChange(ConfigMgr:FromStringTable(StringTablePath.ST_PlayerProfile, "GameModeAll"))
end
function RoleMatchDataPanel:UpdateView(infoShown)
  if self.WS_Content then
    if infoShown.totalMatchNum and 0 ~= infoShown.totalMatchNum then
      if self.ScrollBox_RoleData then
        local roleMatchInfoItems = self.ScrollBox_RoleData:GetAllChildren()
        local itemCount = roleMatchInfoItems:Length()
        local itemIndex = 0
        for key, value in pairsByKeys(infoShown.roleMatch, function(a, b)
          if infoShown.roleMatch[a].matchCount.count == infoShown.roleMatch[b].matchCount.count then
            return infoShown.roleMatch[a].matchCount.winCount > infoShown.roleMatch[b].matchCount.winCount
          else
            return infoShown.roleMatch[a].matchCount.count > infoShown.roleMatch[b].matchCount.count
          end
        end) do
          itemIndex = itemIndex + 1
          if itemCount >= itemIndex then
            roleMatchInfoItems:Get(itemIndex):UpdateView(infoShown.totalMatchNum, value)
            roleMatchInfoItems:Get(itemIndex):SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          elseif self.itemPanelClass:IsValid() then
            local itemPanel = UE4.UWidgetBlueprintLibrary.Create(self, self.itemPanelClass)
            if itemPanel then
              itemPanel:UpdateView(infoShown.totalMatchNum, value)
              self.ScrollBox_RoleData:AddChild(itemPanel)
            else
              LogDebug("RoleMatchDataPanel", "Panel create failed")
            end
          else
            LogDebug("RoleMatchDataPanel", "Panel class load failed")
          end
        end
        if itemCount > itemIndex then
          for index = itemIndex + 1, itemCount do
            roleMatchInfoItems:Get(index):SetVisibility(UE4.ESlateVisibility.Collapsed)
          end
        end
      end
      self.WS_Content:SetActiveWidgetIndex(0)
    else
      self.WS_Content:SetActiveWidgetIndex(1)
    end
  end
end
function RoleMatchDataPanel:Construct()
  RoleMatchDataPanel.super.Construct(self)
  self.gameModeMap = {}
  if self.ComboBox_Career then
    local allModeText = ConfigMgr:FromStringTable(StringTablePath.ST_PlayerProfile, "GameModeAll")
    self.gameModeMap[allModeText] = 0
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
        self.ComboBox_Career:AddOption(gameText)
        self.gameModeMap[gameText] = GameModeEnum.gameModeMap[value]
      end
    end
    self.ComboBox_Career.OnSelectionChanged:Add(self, self.OnGameModeChange)
    self.ComboBox_Career.OnMenuOpenChanged:Add(self, self.OnMenuOpen)
  end
  if self.RoleMatchItemPanel then
    self.itemPanelClass = ObjectUtil:LoadClass(self.RoleMatchItemPanel)
    if not self.itemPanelClass:IsValid() then
      LogDebug("RoleMatchDataPanel", "Panel class load failed")
    end
  end
end
function RoleMatchDataPanel:Destruct()
  if self.ComboBox_Career then
    self.ComboBox_Career.OnSelectionChanged:Remove(self, self.OnGameModeChange)
    self.ComboBox_Career.OnMenuOpenChanged:Remove(self, self.OnMenuOpen)
  end
  RoleMatchDataPanel.super.Destruct(self)
end
function RoleMatchDataPanel:OnGameModeChange(selectedItem, selectionType)
  GameFacade:SendNotification(NotificationDefines.PlayerProfile.PlayerData.GetRoleMatchDataCmd, self.gameModeMap[selectedItem])
end
function RoleMatchDataPanel:OnMenuOpen(isOpen)
  if self.Image_ArrowR then
    if isOpen then
      self.Image_ArrowR:SetRenderScale(UE4.FVector2D(1, 1))
    else
      self.Image_ArrowR:SetRenderScale(UE4.FVector2D(1, -1))
    end
  end
end
return RoleMatchDataPanel
