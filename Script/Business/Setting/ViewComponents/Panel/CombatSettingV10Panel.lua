local CombatSettingV10Panel = class("CombatSettingV10Panel", PureMVC.ViewComponentPanel)
local CombatSettingPanelMediator = require("Business/Setting/Mediators/CombatSettingPanelMediator")
function CombatSettingV10Panel:ListNeededMediators()
  return {CombatSettingPanelMediator}
end
function CombatSettingV10Panel:InitializeLuaEvent()
  self.CheckBox_AllCompetitorChat.OnCheckStateChanged:Add(self, self.OnAllCompetitorChat)
  local uiAllTeam = {}
  for i = 1, 10 do
    uiAllTeam[i] = self["WBP_MyCombatSettingItem" .. i]
    uiAllTeam[i]:SetV10(true)
  end
  self._uiAllTeam = uiAllTeam
  self._dataAllTeam = {}
end
function CombatSettingV10Panel:SetData(data)
  local allTeamData = {}
  for i, v in ipairs(data.MyTeamData) do
    allTeamData[#allTeamData + 1] = v
  end
  for i, v in ipairs(data.EnemyTeamData) do
    allTeamData[#allTeamData + 1] = v
  end
  self._dataAllTeam = allTeamData
  LogInfo("CombatSettingV10Panel", "SetData")
  table.print(allTeamData)
end
function CombatSettingV10Panel:RefreshView()
  for i = 1, 10 do
    local data = self._dataAllTeam[i]
    local ui = self._uiAllTeam[i]
    if data then
      ui:SetItemData(data, i)
    else
      ui:SetFreeStatus(true)
    end
  end
  local SettingCombatProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCombatProxy)
  self:SetAllCompetitorChatChecked(SettingCombatProxy.allWordChatStatus)
end
function CombatSettingV10Panel:SetAllCompetitorChatChecked(bChecked)
  self.CheckBox_AllCompetitorChat:SetIsChecked(bChecked)
  local SettingCombatProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCombatProxy)
  SettingCombatProxy.allWordChatStatus = bChecked
end
function CombatSettingV10Panel:OnAllCompetitorChat(bIsChecked)
  LogInfo("CombatSettingV10Panel", "OnAllCompetitorChat" .. tostring(bIsChecked))
  if bIsChecked then
    for i = 2, 10 do
      local ui = self._uiAllTeam[i]
      ui:SetWordChatOpen(false)
    end
  end
  self:SetAllCompetitorChatChecked(bIsChecked)
end
function CombatSettingV10Panel:OnClose()
  LogInfo("CombatSettingV10Panel", "OnClose")
  self._uiAllTeam = {}
  self._dataAllTeam = {}
end
return CombatSettingV10Panel
