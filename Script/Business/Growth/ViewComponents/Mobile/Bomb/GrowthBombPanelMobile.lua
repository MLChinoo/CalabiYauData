local GrowthBombPanelMobile = class("GrowthBombPanelMobile", PureMVC.ViewComponentPanel)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
local GrowthPageMediator = require("Business/Growth/Mediators/GrowthPageMediator")
function GrowthBombPanelMobile:ListNeededMediators()
  return {GrowthPageMediator}
end
function GrowthBombPanelMobile:Construct()
  self.Button_Close.OnClicked:Add(self, self.OnExitButtonClicked)
  GrowthBombPanelMobile.super.Construct(self)
  self.Overridden.Construct(self)
  self:SetPartSlotType()
  if self.SkillWakeDetail then
    self.SkillWakeDetail:SetWakeItemType()
  end
  GameFacade:SendNotification(NotificationDefines.Growth.GrowthLevelUpdateCmd)
  self.CheckBox_Wake.OnCheckStateChanged:Add(self, GrowthBombPanelMobile.OnWakeCheckStateChanged)
  self.CheckBox_Detail.OnCheckStateChanged:Add(self, GrowthBombPanelMobile.OnDetailCheckStateChanged)
  self:OnWakeCheckStateChanged(true)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local GrowthComponent = MyPlayerState:GetGrowthComponent()
  if GrowthComponent and GrowthComponent.OnArousalMaskChanged then
    self.OnArousalMaskChangedHandle = DelegateMgr:AddDelegate(GrowthComponent.OnArousalMaskChanged, self, "OnArousalMaskChanged")
  end
  self.lastRemainingTime = 0
  if self.TextBlock_RemainingTime and self.TextBlock_Ready then
    local LeftTime = GameState:GetRemainingTime()
    if LeftTime > self.StartPlayAnimation or LeftTime < 0.1 then
      self.TextBlock_RemainingTime:SetColorAndOpacity(self.TextBlock_Ready.ColorAndOpacity)
    end
  end
end
function GrowthBombPanelMobile:Destruct()
  self.Button_Close.OnClicked:Remove(self, self.OnExitButtonClicked)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
  GrowthBombPanelMobile.super.Destruct(self)
  self.CheckBox_Wake.OnCheckStateChanged:Remove(self, GrowthBombPanelMobile.OnWakeCheckStateChanged)
  self.CheckBox_Detail.OnCheckStateChanged:Remove(self, GrowthBombPanelMobile.OnDetailCheckStateChanged)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local GrowthComponent = MyPlayerState:GetGrowthComponent()
  if GrowthComponent and GrowthComponent.OnArousalMaskChanged then
    DelegateMgr:RemoveDelegate(GrowthComponent.OnArousalMaskChanged, self.OnArousalMaskChangedHandle)
  end
  if self.PS_Active_Bg then
    self.PS_Active_Bg:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Anim_Scale then
    self:StopAnimation(self.Anim_Scale)
  end
end
function GrowthBombPanelMobile:UpdateBaseInfo(GrowthBaseInfo)
  self.TextBlock_RoleName:SetText(GrowthBaseInfo.RoleNameCn)
  self.TextBlock_WeaponName:SetText(GrowthBaseInfo.WeaponName)
  self.Image_WeaponIcon:SetBrushFromSoftTexture(GrowthBaseInfo.WeaponIcon)
end
function GrowthBombPanelMobile:UpdateGrowthPoint(GrowthPoint)
  self.TextBlock_GrowthPoint:SetText(math.floor(GrowthPoint))
end
function GrowthBombPanelMobile:SetPartSlotType()
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
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  if GameState and MyPlayerController and MyPlayerState and GrowthProxy then
    local QSkillUpgradeCnt = GrowthProxy:GetGrowthSlotLvMax(MyPlayerState.SelectRoleId, UE4.EGrowthSlotType.QSkill)
    local PassiveSkillUpgradeCnt = GrowthProxy:GetGrowthSlotLvMax(MyPlayerState.SelectRoleId, UE4.EGrowthSlotType.PassiveSkill)
    if QSkillUpgradeCnt < PassiveSkillUpgradeCnt then
      SlotTypeTable[5] = UE4.EGrowthSlotType.PassiveSkill
      SlotTypeTable[6] = UE4.EGrowthSlotType.QSkill
    end
  end
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
function GrowthBombPanelMobile:OnExitButtonClicked()
  ViewMgr:HidePage(self, UIPageNameDefine.GrowthPage)
end
function GrowthBombPanelMobile:UpdateWakeItem()
  if self.SkillWakeDetail then
    self.SkillWakeDetail:UpdateWakeItem()
  end
end
function GrowthBombPanelMobile:OnLevelChanged()
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
          LogError("GrowthBombPanelMobile", "OnLevelChanged Slot=%s is Error", Slot)
        end
        local Geometry = PartBP.WBP_Icon.Switch_Bg:GetCachedGeometry()
        local LocalPos = PartBP.WBP_Icon.Switch_Bg.Slot:GetPosition()
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
function GrowthBombPanelMobile:OnWakeCheckStateChanged(bIsChecked)
  if self.CheckBox_Wake then
    if bIsChecked then
      if self.CheckBox_Detail then
        self.CheckBox_Detail:SetIsChecked(false)
      end
      if self.CanvasPanel_Detail then
        self.CanvasPanel_Detail:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      if self.SkillWakeDetail then
        self.SkillWakeDetail:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
    self.CheckBox_Wake:SetIsChecked(true)
  end
end
function GrowthBombPanelMobile:OnDetailCheckStateChanged(bIsChecked)
  if self.CheckBox_Detail then
    if bIsChecked then
      if self.CheckBox_Wake then
        self.CheckBox_Wake:SetIsChecked(false)
      end
      if self.SkillWakeDetail then
        self.SkillWakeDetail:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      if self.CanvasPanel_Detail then
        self.CanvasPanel_Detail:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
    self.CheckBox_Detail:SetIsChecked(true)
  end
end
function GrowthBombPanelMobile:CreateActiveFlyEffect(Slot, AbsolutePos)
  local Geometry = self.CanvasPanel_Growth:GetCachedGeometry()
  if not self.FlyTargetPos then
    local targetAbsolute = UE4.UPMWidgetBlueprintLibrary.GetAbsolutePosition(self.CheckBox_Wake)
    self.FlyTargetPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(Geometry, targetAbsolute)
  end
  local LocalPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(Geometry, AbsolutePos)
  local FlyEffect = UE4.UWidgetBlueprintLibrary.Create(self, self.FlyEffectClass)
  self.CanvasPanel_Growth:AddChildToCanvas(FlyEffect)
  if not self.FlyEffects then
    self.FlyEffects = {}
  end
  self.FlyEffects[Slot] = FlyEffect
  self.FlyEffects[Slot].Slot:SetZOrder(100)
  self.FlyEffects[Slot].Slot:SetSize(UE4.FVector2D(0, 0))
  self.FlyEffects[Slot].Slot:SetPosition(LocalPos)
end
function GrowthBombPanelMobile:DestroyActiveFlyEffect(Slot)
  if self.FlyEffects then
    if self.FlyEffects[Slot] then
      self.FlyEffects[Slot]:RemoveFromViewport()
    end
    self.FlyEffects[Slot] = nil
  end
end
function GrowthBombPanelMobile:OnArousalMaskChanged()
  if not self:IsFlyEffectExist() then
    self:UpdateWakeItem()
  end
end
function GrowthBombPanelMobile:IsFlyEffectExist()
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
function GrowthBombPanelMobile:Tick(MyGeometry, InDeltaTime)
  self:SetRemainingTime()
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
function GrowthBombPanelMobile:SetRemainingTime()
  local GameState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if GameState and self.TextBlock_RemainingTime then
    self.remainingTime = math.ceil(GameState:GetRemainingTime())
    if self.lastRemainingTime ~= self.remainingTime then
      local mins = math.modf(self.remainingTime / 60)
      local secs = self.remainingTime % 60
      if self.Anim_Scale and not self:IsAnimationPlaying(self.Anim_Scale) and self.remainingTime <= self.StartPlayAnimation and 0 ~= self.lastRemainingTime then
        self:PlayAnimationForward(self.Anim_Scale, 1, false)
      end
      self.lastRemainingTime = self.remainingTime
      self.TextBlock_RemainingTime:SetText(string.format("%02d : %02d", mins, secs))
    end
  end
end
return GrowthBombPanelMobile
