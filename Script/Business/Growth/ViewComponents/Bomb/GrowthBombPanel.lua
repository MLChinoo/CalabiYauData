local GrowthBombPanel = class("GrowthBombPanel", PureMVC.ViewComponentPanel)
local GrowthPageMediator = require("Business/Growth/Mediators/GrowthPageMediator")
function GrowthBombPanel:ListNeededMediators()
  return {GrowthPageMediator}
end
function GrowthBombPanel:Construct()
  self.Button_Close.OnClicked:Add(self, self.OnExitButtonClicked)
  GrowthBombPanel.super.Construct(self)
  self.Overridden.Construct(self)
  self:SetPartSlotType()
  if self.WBP_GrowthWakePanel_PC then
    self.WBP_GrowthWakePanel_PC:SetWakeItemType()
  end
  self:OnLevelChanged()
  GameFacade:SendNotification(NotificationDefines.Growth.GrowthLevelUpdateCmd)
end
function GrowthBombPanel:Destruct()
  self.Button_Close.OnClicked:Remove(self, self.OnExitButtonClicked)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
  GrowthBombPanel.super.Destruct(self)
end
function GrowthBombPanel:UpdateBaseInfo(GrowthBaseInfo)
  self.TextBlock_RoleName:SetText(GrowthBaseInfo.RoleNameCn)
  self.TextBlock_WeaponName:SetText(GrowthBaseInfo.WeaponName)
  self.Image_WeaponIcon:SetBrushFromSoftTexture(GrowthBaseInfo.WeaponIcon)
end
function GrowthBombPanel:UpdateGrowthPoint(GrowthPoint)
  self.TextBlock_GrowthPoint:SetText(math.floor(GrowthPoint))
end
function GrowthBombPanel:SetPartSlotType()
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
function GrowthBombPanel:OnExitButtonClicked()
  ViewMgr:HidePage(self, UIPageNameDefine.GrowthPage)
end
function GrowthBombPanel:CreateActiveFlyEffect(Slot, AbsolutePos)
  if self.WBP_GrowthWakePanel_PC then
    self.WBP_GrowthWakePanel_PC:CreateActiveFlyEffect(Slot, AbsolutePos)
  end
end
function GrowthBombPanel:DestroyActiveFlyEffect(Slot)
  if self.WBP_GrowthWakePanel_PC then
    self.WBP_GrowthWakePanel_PC:DestroyActiveFlyEffect(Slot)
  end
end
function GrowthBombPanel:UpdateWakeItem()
  if self.WBP_GrowthWakePanel_PC then
    self.WBP_GrowthWakePanel_PC:UpdateWakeItem()
  end
end
function GrowthBombPanel:OnLevelChanged()
  local LocalPlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0)
  local MyPlayerState = LocalPlayerController and LocalPlayerController.PlayerState
  if not MyPlayerState then
    return
  end
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  local PartsLvNew = {}
  for Slot = UE4.EGrowthSlotType.WeaponPart_Muzzle, UE4.EGrowthSlotType.Survive do
    PartsLvNew[Slot] = GrowthProxy:GetGrowthLv(MyPlayerState, Slot)
  end
  if self.PartsLvCache then
    for Slot, value in pairs(PartsLvNew) do
      if self.PartsLvCache[Slot] ~= value then
        local IsMax = GrowthProxy:IsSlotMaxLv(MyPlayerState, Slot)
        local PartBP = self.PartBPS[Slot]
        if not PartBP then
          LogError("GrowthBombPanel", "OnLevelChanged Slot=%s is Error", Slot)
        end
        local Geometry = PartBP.WBP_Icon.Switch_Bg:GetCachedGeometry()
        local LocalPos = PartBP.WBP_Icon.Switch_Bg.Slot:GetPosition() - PartBP.WBP_Icon.Switch_Bg.Slot:GetSize() / 2
        local AbsolutePos = UE4.USlateBlueprintLibrary.LocalToAbsolute(Geometry, LocalPos)
        if IsMax then
          local PartBP = self.PartBPS[Slot]
          if PartBP then
            PartBP:ShowActiveEffect()
          end
          self:CreateActiveFlyEffect(Slot, AbsolutePos)
        else
          self:DestroyActiveFlyEffect(Slot)
          self:UpdateWakeItem()
        end
      end
    end
  end
  self.PartsLvCache = PartsLvNew
end
return GrowthBombPanel
