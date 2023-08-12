local CombatSettingPanel = class("CombatSettingPanel", PureMVC.ViewComponentPanel)
local CombatSettingPanelMediator = require("Business/Setting/Mediators/CombatSettingPanelMediator")
function CombatSettingPanel:ListNeededMediators()
  return {CombatSettingPanelMediator}
end
function CombatSettingPanel:InitializeLuaEvent()
  self.CheckBox_AllCompetitorChat.OnCheckStateChanged:Add(self, self.OnAllCompetitorChat)
  local uiMyTeam = {}
  local uiEnemyTeam = {}
  for i = 1, 5 do
    uiMyTeam[i] = self["WBP_MyCombatSettingItem" .. i]
    uiEnemyTeam[i] = self["WBP_EnemyCombatSettingItem" .. i]
  end
  self._uiMyTeam = uiMyTeam
  self._uiEnemyTeam = uiEnemyTeam
  self._dataMyTeam = {}
  self._dataEnemyTeam = {}
end
function CombatSettingPanel:SetData(data)
  self._dataEnemyTeam = data.EnemyTeamData
  self._dataMyTeam = data.MyTeamData
  LogInfo("CombatSettingPanel", "SetData")
  table.print(data)
end
function CombatSettingPanel:RefreshView()
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
    local data = self._dataEnemyTeam[i]
    local ui = self._uiEnemyTeam[i]
    if data then
      ui:SetItemData(data, i)
    else
      ui:SetFreeStatus(true)
    end
  end
  local SettingCombatProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCombatProxy)
  self:SetAllCompetitorChatChecked(SettingCombatProxy.allWordChatStatus)
end
function CombatSettingPanel:SetAllCompetitorChatChecked(bChecked)
  self.CheckBox_AllCompetitorChat:SetIsChecked(bChecked)
  local SettingCombatProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCombatProxy)
  SettingCombatProxy.allWordChatStatus = bChecked
end
function CombatSettingPanel:OnAllCompetitorChat(bIsChecked)
  LogInfo("CombatSettingPanel", "OnAllCompetitorChat" .. tostring(bIsChecked))
  if bIsChecked then
    for i = 1, 5 do
      local ui = self._uiEnemyTeam[i]
      ui:SetWordChatOpen(false)
    end
  end
  self:SetAllCompetitorChatChecked(bIsChecked)
end
function CombatSettingPanel:OnClose()
  LogInfo("CombatSettingPanel", "OnClose")
  self._uiMyTeam = {}
  self._uiEnemyTeam = {}
  self._dataMyTeam = {}
  self._dataEnemyTeam = {}
end
return CombatSettingPanel
