local RolePersonalityPanelMeditor = require("Business/EquipRoom/Mediators/CharacterPreinstallPanel/RolePersonalityPanelMeditor")
local TabBasePanel = require("Business/EquipRoom/ViewCompent/TabBasePanel/TabBasePanel")
local RolePersonalityPanel = class("RolePersonalityPanel", TabBasePanel)
function RolePersonalityPanel:ListNeededMediators()
  return {RolePersonalityPanelMeditor}
end
function RolePersonalityPanel:InitializeLuaEvent()
  RolePersonalityPanel.super.InitializeLuaEvent(self)
  if self.EmoteGridsPanel then
    self.EmoteGridsPanel:HideCollectPanel()
  end
  if self.ActionGridsPanel then
    self.ActionGridsPanel:HideCollectPanel()
  end
  RedDotTree:Bind(RedDotModuleDef.ModuleName.EquipRoomCommuicationAction, function(cnt)
    self:UpdateRedDotByCustomType(cnt, 2)
  end)
  self:UpdateRedDotByCustomType(0, 2)
  RedDotTree:Bind(RedDotModuleDef.ModuleName.EquipRoomPersonalEmote, function(cnt)
    self:UpdateRedDotByCustomType(cnt, 1)
  end)
  self:UpdateRedDotByCustomType(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomPersonalEmote), 1)
  self:UpdateKetTips()
  self.allCharacterEquipEvent = LuaEvent.new()
  if self.Btn_AllCharacterEquip then
    self.Btn_AllCharacterEquip.OnClickEvent:Add(self, self.AllCharacterEquip)
  end
end
function RolePersonalityPanel:Destruct()
  RolePersonalityPanel.super.Destruct(self)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.EquipRoomCommuicationAction)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.EquipRoomPersonalEmote)
  if self.Btn_AllCharacterEquip then
    self.Btn_AllCharacterEquip.OnClickEvent:Remove(self, self.AllCharacterEquip)
  end
end
function RolePersonalityPanel:OnShowPanel()
  if self.MainPage then
    self.MainPage:HideViewTips()
  end
  self:UpdatePanelRedDot()
end
function RolePersonalityPanel:OnHidePanel()
  self:RestEmote()
end
function RolePersonalityPanel:ClearPanelExpend()
  if self.NavigationBar then
  end
  if self.RoulettePanel then
  end
end
function RolePersonalityPanel:UpdateRedDotByCustomType(cnt, tabPanelIndex)
  if self.NavigationBar then
    local equiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
    local redProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy)
    local bShow = false
    if 1 == tabPanelIndex then
      bShow = cnt > 0
    else
      local roleIDList = redProxy:GetRoleIDListByCommunicationActionRedDot()
      for key, value in pairs(roleIDList) do
        if value == equiproomProxy:GetSelectRoleID() then
          bShow = true
          break
        end
      end
    end
    local barItem = self.NavigationBar:GetBarByCustomType(tabPanelIndex)
    if barItem then
      barItem:SetRedDotVisible(bShow)
    end
  end
end
function RolePersonalityPanel:UpdateKetTips()
  local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "TacticalRouletteKeyTips")
  local keyName = self:GetKeyName("PersonalRoulette")
  if keyName and self.RoulettePanel then
    local stringMap = {
      ["0"] = keyName
    }
    local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    self.RoulettePanel:SetKeyTips(text)
  end
end
function RolePersonalityPanel:GetKeyName(keyName)
  local settingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  local key1, key2 = settingInputUtilProxy:GetKeyByInputName(keyName)
  if key1 and 0 ~= string.len(key1) then
    return key1
  else
    return key2
  end
end
function RolePersonalityPanel:ShowCharacterEmote(emoteID)
  if self.MainPage and self.MainPage.WBP_ItemDisplayKeys then
    local data = {}
    data.itemId = emoteID
    data.bNotChangeRole = true
    self.MainPage.WBP_ItemDisplayKeys:SetItemDisplayed(data)
  end
end
function RolePersonalityPanel:RestEmote()
  if self.MainPage and self.MainPage.WBP_ItemDisplayKeys then
    self.MainPage.WBP_ItemDisplayKeys:RestEmote()
  end
end
function RolePersonalityPanel:StopCharacterAction()
  if self.MainPage and self.MainPage.WBP_ItemDisplayKeys then
    self.MainPage.WBP_ItemDisplayKeys:StopCharacterAction()
  end
end
function RolePersonalityPanel:SetCharacterEnableLeisure(bEnable)
  if self.MainPage and self.MainPage.WBP_ItemDisplayKeys then
    self.MainPage.WBP_ItemDisplayKeys:SetCharacterEnableLeisure(bEnable)
  end
end
function RolePersonalityPanel:AllCharacterEquip()
  self.allCharacterEquipEvent()
end
function RolePersonalityPanel:UpdatePanelRedDot()
  self:UpdateRedDotByCustomType(0, 2)
  self:UpdateRedDotByCustomType(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomPersonalEmote), 1)
end
return RolePersonalityPanel
