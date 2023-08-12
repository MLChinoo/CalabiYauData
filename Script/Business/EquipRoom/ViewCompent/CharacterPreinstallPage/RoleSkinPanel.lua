local RoleSkinPanelMeditor = require("Business/EquipRoom/Mediators/CharacterPreinstallPanel/RoleSkinPanelMeditor")
local TabBasePanel = require("Business/EquipRoom/ViewCompent/TabBasePanel/TabBasePanel")
local RoleSkinPanel = class("RoleSkinPanel", TabBasePanel)
function RoleSkinPanel:ListNeededMediators()
  return {RoleSkinPanelMeditor}
end
function RoleSkinPanel:OnInitialized()
  RoleSkinPanel.super.OnInitialized(self)
  self.OnShowCharacterDrawingEvent = LuaEvent.new()
end
function RoleSkinPanel:Construct()
  RoleSkinPanel.super.Construct(self)
  if self.Btn_ShowCharacterDrawing then
    self.Btn_ShowCharacterDrawing.OnClicked:Add(self, self.OnShowCharacterDrawing)
  end
  self:SetDrawBtnName()
end
function RoleSkinPanel:Destruct()
  RoleSkinPanel.super.Destruct(self)
  if self.Btn_ShowCharacterDrawing then
    self.Btn_ShowCharacterDrawing.OnClicked:Remove(self, self.OnShowCharacterDrawing)
  end
end
function RoleSkinPanel:OnShowPanel()
  if self.MainPage then
    self.MainPage:ShowViewTips()
    self:ShowScreenShotKey(true)
  end
end
function RoleSkinPanel:OnHidePanel()
  self:ShowScreenShotKey(false)
end
function RoleSkinPanel:GetSelectItem()
  if self.itemListPanel then
    local item = self.itemListPanel:GetSelectItem()
    if item then
      return item
    end
  end
  return nil
end
function RoleSkinPanel:SetFlyState(bFly)
  if self.MainPage and self.MainPage.WBP_ItemDisplayKeys and self.MainPage.WBP_ItemDisplayKeys.Display3DModelResult then
    local character = self.MainPage.WBP_ItemDisplayKeys.Display3DModelResult:RetrieveLobbyCharacter(0)
    if character then
      character:SetFlyState(bFly)
    end
  end
end
function RoleSkinPanel:SetShowCharacterDrawingBtnVisible(bShow)
  if self.Btn_ShowCharacterDrawing then
    self.Btn_ShowCharacterDrawing:SetVisibility(bShow and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  end
end
function RoleSkinPanel:OnShowCharacterDrawing()
  self.OnShowCharacterDrawingEvent()
end
function RoleSkinPanel:SetDrawBtnName()
  local roleSkinNoUnlockDrawingTips = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "CharacterDrawingBtnName")
  if self.Tex_DrawBtnName then
    self.Tex_DrawBtnName:SetText(roleSkinNoUnlockDrawingTips)
  end
end
return RoleSkinPanel
