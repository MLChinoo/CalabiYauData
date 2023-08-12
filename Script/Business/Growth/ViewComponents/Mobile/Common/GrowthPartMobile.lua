local PartState = {}
PartState.Upgradeable = 0
PartState.CannotUpgrade = 1
PartState.MaxLevel = 2
local AkOnMouseHovered = "AkOnMouseHovered"
local AkOnCannotUpgrade = "AkOnCannotUpgrade"
local AkOnUpgrade = "AkOnUpgrade"
local AkOnDowngrade = "AkOnDowngrade"
local AkOnMaxLevel = "AkOnMaxLevel"
local GrowthPartMobile = class("GrowthPartMobile", PureMVC.ViewComponentPanel)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
local GrowthPartMediator = require("Business/Growth/Mediators/GrowthPartMediator")
function GrowthPartMobile:ListNeededMediators()
  return {GrowthPartMediator}
end
function GrowthPartMobile:InitializeLuaEvent()
  GrowthPartMobile.super.InitializeLuaEvent(self)
  self.OnRevertBtnClicked = LuaEvent.new()
end
function GrowthPartMobile:Construct()
  self.Btn_Revert.OnClicked:Add(self, self.OnButtonRevertClick)
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  if GrowthProxy:IsGrowthPartUpgradeManual(self) then
    self.Btn_Revert:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Btn_Revert:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  GrowthPartMobile.super.Construct(self)
  self:PlayAnimation(self.Ani_Active, 0, 0)
  self.Canvas_Active:SetVisibility(UE4.ESlateVisibility.Hidden)
end
function GrowthPartMobile:Destruct()
  self.Btn_Revert.OnClicked:Remove(self, self.OnButtonRevertClick)
  if self.WBP_Icon.Ps_MaxLv_Active then
    self.WBP_Icon.Ps_MaxLv_Active:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  GrowthPartMobile.super.Destruct(self)
end
function GrowthPartMobile:OnButtonRevertClick()
  self.OnRevertBtnClicked(self.SlotType, true)
end
function GrowthPartMobile:UpdatePartState()
  local GameState = UE4.UGameplayStatics.GetGameState(self)
  if not GameState then
    return
  end
  if not self.PartData then
    return
  end
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  local bMaxLevel = self.PartData.CurrentLevel >= self.PartData.MaxLevel
  if self.PartData.SingleSelect then
    bMaxLevel = self.PartData.CurrentLevel > 0
  end
  if bMaxLevel then
    self.PartState = PartState.MaxLevel
  else
    if self.PartData.GrowthPoint >= self.PartData.UpgradeCost then
      self.PartState = PartState.Upgradeable
    else
      self.PartState = PartState.CannotUpgrade
    end
    if GameState:GetModeType() == UE4.EPMGameModeType.Bomb and GameState:GetRoundState() ~= UE4.ERoundStage.Freeze then
      self.PartState = PartState.CannotUpgrade
    end
  end
  self.Upgradeable = GrowthProxy:IsGrowthPartUpgradeManual(self) and self.PartState == PartState.Upgradeable
  self:OnUpdatePartState()
end
function GrowthPartMobile:OnUpdatePartState()
  self.WBP_Icon.Ps_MaxLv:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.PartState == PartState.Upgradeable then
    self.Text_Name:SetColorAndOpacity(self.NameColorUpgradeable)
    self.Switch_TitleBg:SetActiveWidgetIndex(0)
    self.Canvas_Active:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif self.PartState == PartState.CannotUpgrade then
    self.Text_Name:SetColorAndOpacity(self.NameColorCannotUpgrade)
    self.Switch_TitleBg:SetActiveWidgetIndex(1)
    self.Canvas_Active:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif self.PartState == PartState.MaxLevel then
    self.Text_Name:SetColorAndOpacity(self.NameColorCannotUpgrade)
    self.Switch_TitleBg:SetActiveWidgetIndex(1)
    self.WBP_Icon.Ps_MaxLv:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Canvas_Active:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end
function GrowthPartMobile:UpdatePart()
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if self.SlotType == UE4.EGrowthSlotType.None then
    return
  end
  self.PartData = {}
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local RoleRow = roleProxy:GetRole(MyPlayerState.SelectRoleId)
  self.PartData.SlotType = self.SlotType
  self.PartData.CurrentLevel = GrowthProxy:GetGrowthLv(MyPlayerState, self.SlotType)
  self.PartData.TempCurrentLevel = GrowthProxy:GetGrowthTempLv(MyPlayerState, self.SlotType)
  self.PartData.MaxLevel = GrowthProxy:GetGrowthSlotLvMax(MyPlayerState.SelectRoleId, self.SlotType)
  self.PartData.SingleSelect = GrowthProxy:IsSingleSelect(MyPlayerState.SelectRoleId, self.SlotType)
  self.PartData.CurrentLevel = self.PartData.CurrentLevel and self.PartData.CurrentLevel or 0
  self.PartData.UpgradeCost = GrowthProxy:GetGrowthSlotCost(MyPlayerState.SelectRoleId, self.SlotType, self.PartData.CurrentLevel + 1)
  self.PartData.bSkillSlot = GrowthProxy:IsSkillSlot(self.SlotType)
  if self.SlotType == UE4.EGrowthSlotType.QSkill then
    self.PartData.SkillId = RoleRow.SkillActive:Get(1)
  elseif self.SlotType == UE4.EGrowthSlotType.PassiveSkill then
    self.PartData.SkillId = RoleRow.SkillPassive:Get(1)
  elseif self.SlotType == UE4.EGrowthSlotType.Survive then
    self.PartData.SkillId = MyPlayerState.SelectRoleId * 10 + 7
  elseif self.SlotType == UE4.EGrowthSlotType.Shield then
    self.PartData.SkillId = MyPlayerState.SelectRoleId * 10 + 8
  end
  if self.PartData.SkillId then
    self.PartData.SkillRow = roleProxy:GetRoleSkill(self.PartData.SkillId)
    if not self.PartData.SkillRow then
      LogError("Get Skill Table Error", "SkillId=%s", self.PartData.SkillId)
    end
  end
  self.PartData.GrowthPoint = MyPlayerState.CurrentGrowthPoint
  self:UpdatePartState()
  if self.WBP_Recommend then
    local IsRecommend = GrowthProxy:IsRecommendSlot(MyPlayerState, self.SlotType)
    self.WBP_Recommend:SetRecommend(self.Upgradeable and IsRecommend)
  end
  if self.PartData.bSkillSlot and self.PartData.SkillRow then
    self.Text_Name:SetText(self.PartData.SkillRow.Name)
  elseif self.SlotType == UE4.EGrowthSlotType.Shield or self.SlotType == UE4.EGrowthSlotType.Survive then
    self.Text_Name:SetText(self.PartData.SkillRow.Name)
  else
    self.Text_Name:SetText(GrowthProxy:GetGrowthPartSlotName(MyPlayerState.SelectRoleId, self.SlotType))
  end
  self.WBP_Icon.Switch_Bg:SetActiveWidgetIndex(self.PartState == PartState.MaxLevel and 1 or 0)
  if self.PartState ~= PartState.MaxLevel then
    self.WBP_Icon.Ps_MaxLv_Active:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.PartData.bSkillSlot then
    self.WBP_Icon.Image_Icon:SetBrushFromSoftTexture(self.PartData.SkillRow.IconSkill)
    self.WBP_Icon.Image_Icon:SetBrushTintColor(self.PartState == PartState.MaxLevel and self.IconAcitveTintColor or self.IconUnAcitveTintColor)
  else
    local Image_Icon = self.WBP_Icon.NamedSlot_Icon:GetChildAt(0):GetChildAt(0)
    Image_Icon:SetBrushTintColor(self.PartState == PartState.MaxLevel and self.IconAcitveTintColor or self.IconUnAcitveTintColor)
  end
  if GameState:GetModeType() == UE4.EPMGameModeType.Practice then
    self.Btn_Revert:SetVisibility(UE4.ESlateVisibility.Hidden)
    if self.PartData.CurrentLevel > 0 then
      self.Btn_Revert:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  elseif GameState:GetModeType() == UE4.EPMGameModeType.Bomb or GameState:GetModeType() == UE4.EPMGameModeType.Spar then
    self.Btn_Revert:SetVisibility(UE4.ESlateVisibility.Hidden)
    if self.PartData.CurrentLevel > 0 and GameState:GetRoundState() <= UE4.ERoundStage.Freeze then
      self.Btn_Revert:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  end
  if self.LastLevel and self.LastLevel >= 0 then
    local AkEvent
    if self.LastLevel < self.PartData.CurrentLevel then
      local bMaxLevel = self.PartData.CurrentLevel >= self.PartData.MaxLevel
      if self.PartData.SingleSelect then
        bMaxLevel = self.PartData.CurrentLevel > 0
      end
      AkEvent = bMaxLevel and self.Ak_Operate:Find(AkOnMaxLevel) or self.Ak_Operate:Find(AkOnUpgrade)
    elseif self.LastLevel > self.PartData.CurrentLevel then
      AkEvent = self.Ak_Operate:Find(AkOnDowngrade)
    end
    self:K2_PostAkEvent(AkEvent)
  end
  self.LastLevel = self.PartData.CurrentLevel
  self:UpdateLvProgressItems()
end
function GrowthPartMobile:UpdateLvProgressItems()
  for i = 1, self.PartData.MaxLevel do
    local ItemData = {}
    ItemData.SlotType = self.SlotType
    ItemData.Lv = i
    local Items = self.VB_Items:GetAllChildren()
    if i > Items:Length() then
      GamePlayGlobal:CreateWidget(self, self.ListItemClass, 1, function(Item)
        if Item then
          local slot = self.VB_Items:AddChildToVerticalBox(Item)
          local margin = UE4.FMargin()
          margin.Bottom = 5
          if slot then
            slot:SetPadding(margin)
          end
          Item:UpdateItem(ItemData)
        end
      end)
    else
      local Item = Items:Get(i)
      Item:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      Item:UpdateItem(ItemData)
    end
  end
  local Items = self.VB_Items:GetAllChildren()
  for i = self.PartData.MaxLevel + 1, Items:Length() do
    local Item = Items:Get(i)
    Item:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function GrowthPartMobile:ShowActiveEffect()
  if self.WBP_Icon.Ps_MaxLv_Active then
    if self.WBP_Icon.Ps_MaxLv_Active:GetVisibility() ~= UE4.ESlateVisibility.SelfHitTestInvisible then
      self.WBP_Icon.Ps_MaxLv_Active:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    self.WBP_Icon.Ps_MaxLv_Active:SetReactivate(true)
  end
end
return GrowthPartMobile
