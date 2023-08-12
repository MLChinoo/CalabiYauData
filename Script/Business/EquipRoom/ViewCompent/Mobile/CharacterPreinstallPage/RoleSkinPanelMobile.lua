local RoleSkinPanelMeditor = require("Business/EquipRoom/Mediators/CharacterPreinstallPanel/RoleSkinPanelMeditor")
local TabBasePanelMobile = require("Business/EquipRoom/ViewCompent/Mobile/TabBasePanel/TabBasePanelMobile")
local RoleSkinPanelMobile = class("RoleSkinPanelMobile", TabBasePanelMobile)
function RoleSkinPanelMobile:ListNeededMediators()
  return {RoleSkinPanelMeditor}
end
function RoleSkinPanelMobile:OnShowPanel()
  if self.MainPage then
    self.MainPage:ShowViewTips()
  end
end
function RoleSkinPanelMobile:Construct()
  RoleSkinPanelMobile.super.Construct(self)
  self.OnShowCharacterDrawingEvent = LuaEvent()
end
function RoleSkinPanelMobile:Destruct()
  RoleSkinPanelMobile.super.Destruct(self)
end
function RoleSkinPanelMobile:SetShowCharacterDrawingBtnVisible(bShow)
  if self.Btn_ShowCharacterDrawing then
    self.Btn_ShowCharacterDrawing:SetVisibility(bShow and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  end
end
return RoleSkinPanelMobile
