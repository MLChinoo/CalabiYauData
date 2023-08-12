local CombatSettingTeamPanel = class("CombatSettingTeamPanel", PureMVC.ViewComponentPanel)
local CombatSettingPanelMediator = require("Business/Setting/Mediators/CombatSettingPanelMediator")
function CombatSettingTeamPanel:ListNeededMediators()
  return {CombatSettingPanelMediator}
end
function CombatSettingTeamPanel:InitializeLuaEvent()
  self.CheckBox_AllCompetitorChat.OnCheckStateChanged:Add(self, self.OnAllCompetitorChat)
  local uiMyTeam = {}
  local uiEnemyTeam = {}
  for i = 1, 5 do
    uiMyTeam[i] = self["WBP_MyCombatSettingItem" .. i]
  end
  for i = 1, 10 do
    uiEnemyTeam[i] = self["WBP_EnemyCombatSettingItem" .. i]
  end
  self._uiMyTeam = uiMyTeam
  self._uiEnemyTeam = uiEnemyTeam
  self._dataMyTeam = {}
  self._dataEnemyTeam = {}
end
function CombatSettingTeamPanel:SetData(data)
  self._dataEnemyTeam = data.EnemyTeamData
  self._dataMyTeam = data.MyTeamData
  LogInfo("CombatSettingTeamPanel", "SetData")
  table.print(data)
end
function CombatSettingTeamPanel:RefreshView()
  for i = 1, 5 do
    local data = self._dataMyTeam[i]
    local ui = self._uiMyTeam[i]
    if data then
      ui:SetItemData(data, i)
    else
      ui:SetFreeStatus(true)
    end
  end
  for i = 1, 5 do
    local data = self._dataEnemyTeam[1][i]
    local ui = self._uiEnemyTeam[i]
    if data then
      ui:SetItemData(data, i)
    else
      ui:SetFreeStatus(true)
    end
  end
  for i = 1, 5 do
    local data = self._dataEnemyTeam[2][i]
    local ui = self._uiEnemyTeam[i + 5]
    if data then
      ui:SetItemData(data, i)
    else
      ui:SetFreeStatus(true)
    end
  end
  local SettingCombatProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCombatProxy)
  self:SetAllCompetitorChatChecked(SettingCombatProxy.allWordChatStatus)
end
function CombatSettingTeamPanel:SetAllCompetitorChatChecked(bChecked)
  self.CheckBox_AllCompetitorChat:SetIsChecked(bChecked)
  local SettingCombatProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCombatProxy)
  SettingCombatProxy.allWordChatStatus = bChecked
end
function CombatSettingTeamPanel:OnAllCompetitorChat(bIsChecked)
  LogInfo("CombatSettingTeamPanel", "OnAllCompetitorChat" .. tostring(bIsChecked))
  if bIsChecked then
    for i = 1, 10 do
      local ui = self._uiEnemyTeam[i]
      ui:SetWordChatOpen(false)
    end
  end
  self:SetAllCompetitorChatChecked(bIsChecked)
end
function CombatSettingTeamPanel:OnClose()
  LogInfo("CombatSettingTeamPanel", "OnClose")
  self._uiMyTeam = {}
  self._uiEnemyTeam = {}
  self._dataMyTeam = {}
  self._dataEnemyTeam = {}
end
return CombatSettingTeamPanel
