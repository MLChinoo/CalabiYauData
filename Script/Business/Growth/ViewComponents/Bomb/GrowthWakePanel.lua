local GrowthWakePanel = class("GrowthWakePanel", PureMVC.ViewComponentPanel)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function GrowthWakePanel:Construct()
  GrowthWakePanel.super.Construct(self)
  self.Overridden.Construct(self)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  self.FlyTargetPos = UE4.FVector2D(self.Border_Bg.Slot:GetPosition().X + 960, self.Border_Bg.Slot:GetPosition().Y + 1180)
  local GrowthComponent = MyPlayerState:GetGrowthComponent()
  if GrowthComponent and GrowthComponent.OnArousalMaskChanged then
    self.OnArousalMaskChangedHandle = DelegateMgr:AddDelegate(GrowthComponent.OnArousalMaskChanged, self, "OnArousalMaskChanged")
  end
  self:UpdateWakeItem()
end
function GrowthWakePanel:Destruct()
  if self.PS_Active_Bg then
    self.PS_Active_Bg:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  GrowthWakePanel.super.Destruct(self)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local GrowthComponent = MyPlayerState:GetGrowthComponent()
  if GrowthComponent and GrowthComponent.OnArousalMaskChanged then
    DelegateMgr:RemoveDelegate(GrowthComponent.OnArousalMaskChanged, self.OnArousalMaskChangedHandle)
  end
end
function GrowthWakePanel:OnArousalMaskChanged()
  if not self:IsFlyEffectExist() then
    self:UpdateWakeItem()
  end
end
function GrowthWakePanel:SetWakeItemType()
  for i = 1, 3 do
    if self["WBP_GrowthWakeItem_" .. i] then
      self["WBP_GrowthWakeItem_" .. i].WakeIdx = i
    end
  end
end
function GrowthWakePanel:CreateActiveFlyEffect(Slot, AbsolutePos)
  local Geometry = self.CanvasPanel_Wake:GetCachedGeometry()
  local LocalPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(Geometry, AbsolutePos)
  local FlyEffect = UE4.UWidgetBlueprintLibrary.Create(self, self.FlyEffectClass)
  self.CanvasPanel_Wake:AddChildToCanvas(FlyEffect)
  if not self.FlyEffects then
    self.FlyEffects = {}
  end
  self.FlyEffects[Slot] = FlyEffect
  self.FlyEffects[Slot].Slot:SetZOrder(100)
  self.FlyEffects[Slot].Slot:SetSize(UE4.FVector2D(0, 0))
  self.FlyEffects[Slot].Slot:SetPosition(LocalPos)
end
function GrowthWakePanel:DestroyActiveFlyEffect(Slot)
  if self.FlyEffects then
    if self.FlyEffects[Slot] then
      self.FlyEffects[Slot]:RemoveFromViewport()
    end
    self.FlyEffects[Slot] = nil
  end
end
function GrowthWakePanel:UpdateWakeItem()
  for i = 1, 3 do
    if self["WBP_GrowthWakeItem_" .. i] then
      self["WBP_GrowthWakeItem_" .. i]:Update()
    end
  end
end
function GrowthWakePanel:IsFlyEffectExist()
  if not self.FlyEffects then
    return false
  end
  for Slot, Effect in pairs(self.FlyEffects) do
    if Effect then
      return true
    end
  end
  return false
end
local FlySpeed = 2000
function GrowthWakePanel:Tick(MyGeometry, InDeltaTime)
  if not self.FlyEffects then
    return
  end
  for Slot, Effect in pairs(self.FlyEffects) do
    if Effect then
      local NewPos = UE4.UKismetMathLibrary.Vector2DInterpTo_Constant(Effect.Slot:GetPosition(), self.FlyTargetPos, InDeltaTime, FlySpeed)
      Effect.Slot:SetPosition(NewPos)
      if UE4.UKismetMathLibrary.EqualEqual_Vector2DVector2D(NewPos, self.FlyTargetPos, 0) then
        self:DestroyActiveFlyEffect(Slot)
        self.PS_Active_Bg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.PS_Active_Bg:SetReactivate(true)
        self:UpdateWakeItem()
      end
    end
  end
end
return GrowthWakePanel
