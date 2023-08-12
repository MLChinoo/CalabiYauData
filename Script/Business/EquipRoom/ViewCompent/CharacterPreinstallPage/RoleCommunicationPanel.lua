local RoleCommuicationPanelMeditor = require("Business/EquipRoom/Mediators/CharacterPreinstallPanel/RoleCommuicationPanelMeditor")
local TabBasePanel = require("Business/EquipRoom/ViewCompent/TabBasePanel/TabBasePanel")
local RoleCommunicationPanel = class("RoleCommunicationPanel", TabBasePanel)
function RoleCommunicationPanel:ListNeededMediators()
  return {RoleCommuicationPanelMeditor}
end
function RoleCommunicationPanel:InitializeLuaEvent()
  RoleCommunicationPanel.super.InitializeLuaEvent(self)
  if self.ItemListPanel then
  end
  RedDotTree:Bind(RedDotModuleDef.ModuleName.EquipRoomCommuicationVoice, function(cnt)
    self:UpdateRedDotByCustomType(cnt, 1)
  end)
  self:UpdateRedDotByCustomType(0, 1)
  self:UpdateKetTips()
end
function RoleCommunicationPanel:Destruct()
  RoleCommunicationPanel.super.Destruct(self)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.EquipRoomCommuicationVoice)
end
function RoleCommunicationPanel:OnShowPanel()
  if self.MainPage then
    self.MainPage:HideViewTips()
  end
end
function RoleCommunicationPanel:ClearPanelExpend()
  if self.NavigationBar then
  end
  if self.RoulettePanel then
  end
end
function RoleCommunicationPanel:UpdateRedDotByCustomType(cnt, tabPanelIndex)
  if self.NavigationBar then
    local equiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
    local redProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy)
    local roleIDList
    if 1 == tabPanelIndex then
      roleIDList = redProxy:GetRoleIDListByCommunicationVoiceRedDot()
    else
      roleIDList = redProxy:GetRoleIDListByCommunicationActionRedDot()
    end
    local bHasRole = false
    for key, value in pairs(roleIDList) do
      if value == equiproomProxy:GetSelectRoleID() then
        bHasRole = true
        break
      end
    end
    local barItem = self.NavigationBar:GetBarByCustomType(tabPanelIndex)
    if barItem then
      barItem:SetRedDotVisible(bHasRole)
    end
  end
end
function RoleCommunicationPanel:UpdateKetTips()
  local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "TacticalRouletteKeyTips")
  local keyName = self:GetKeyName("TacticalRoulette")
  if keyName and self.RoulettePanel then
    local stringMap = {
      ["0"] = keyName
    }
    local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    self.RoulettePanel:SetKeyTips(text)
  end
end
function RoleCommunicationPanel:GetKeyName(keyName)
  local settingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  local key1, key2 = settingInputUtilProxy:GetKeyByInputName(keyName)
  if key1 and 0 ~= string.len(key1) then
    return key1
  else
    return key2
  end
end
return RoleCommunicationPanel
