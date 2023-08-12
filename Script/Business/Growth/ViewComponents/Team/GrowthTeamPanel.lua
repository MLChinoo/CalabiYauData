local GrowthTeamPanel = class("GrowthTeamPanel", PureMVC.ViewComponentPanel)
local GrowthPageMediator = require("Business/Growth/Mediators/GrowthPageMediator")
function GrowthTeamPanel:ListNeededMediators()
  return {GrowthPageMediator}
end
function GrowthTeamPanel:Construct()
  GrowthTeamPanel.super.Construct(self)
  self.Overridden.Construct(self)
  self:SetPartSlotType()
  GameFacade:SendNotification(NotificationDefines.Growth.GrowthLevelUpdateCmd)
  self.Button_Close.OnClicked:Add(self, self.OnExitButtonClicked)
end
function GrowthTeamPanel:Destruct()
  GrowthTeamPanel.super.Destruct(self)
  self.Button_Close.OnClicked:Remove(self, self.OnExitButtonClicked)
end
function GrowthTeamPanel:UpdateBaseInfo(GrowthBaseInfo)
  self.TextBlock_RoleName:SetText(GrowthBaseInfo.RoleNameCn)
  self.TextBlock_WeaponName:SetText(GrowthBaseInfo.WeaponName)
  self.Image_WeaponIcon:SetBrushFromSoftTexture(GrowthBaseInfo.WeaponIcon)
end
function GrowthTeamPanel:UpdateGrowthPoint(GrowthPoint)
  self.TextBlock_GrowthPoint:SetText(math.floor(GrowthPoint))
end
function GrowthTeamPanel:SetPartSlotType()
  local SlotTypeTable = {
    [0] = UE4.EGrowthSlotType.WeaponPart_Muzzle,
    [1] = UE4.EGrowthSlotType.WeaponPart_Sight,
    [3] = UE4.EGrowthSlotType.WeaponPart_Magazine,
    [4] = UE4.EGrowthSlotType.WeaponPart_ButtStock,
    [5] = UE4.EGrowthSlotType.QSkill,
    [6] = UE4.EGrowthSlotType.PassiveSkill,
    [7] = UE4.EGrowthSlotType.Shield,
    [8] = UE4.EGrowthSlotType.Survive
  }
  for i = 0, 8 do
    if self["Part_" .. i] then
      self["Part_" .. i].WBP_GrowthPart.SlotType = SlotTypeTable[i]
      if not self.PartBPS then
        self.PartBPS = {}
      end
      self.PartBPS[SlotTypeTable[i]] = self["Part_" .. i].WBP_GrowthPart
    end
  end
end
function GrowthTeamPanel:OnExitButtonClicked()
  ViewMgr:HidePage(self, UIPageNameDefine.GrowthPage)
end
return GrowthTeamPanel
