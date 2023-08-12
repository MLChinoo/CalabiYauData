local GrowthPartItemMobile = class("GrowthPartItemMobile", PureMVC.ViewComponentPanel)
local AkOnMouseHovered = "AkOnMouseHovered"
local AkOnCannotUpgrade = "AkOnCannotUpgrade"
local AkOnUpgrade = "AkOnUpgrade"
local AkOnDowngrade = "AkOnDowngrade"
local AkOnMaxLevel = "AkOnMaxLevel"
local GrowthDefine = require("Business/Growth/Proxies/GrowthDefine")
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
local GrowthPartItemMediator = require("Business/Growth/Mediators/GrowthPartItemMediator")
function GrowthPartItemMobile:ListNeededMediators()
  return {GrowthPartItemMediator}
end
function GrowthPartItemMobile:UpdateItem(ItemData)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  self.SlotType = ItemData.SlotType
  self.Lv = ItemData.Lv
  self.PartData = {}
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local RoleRow = roleProxy:GetRole(MyPlayerState.SelectRoleId)
  self.PartData.SlotType = self.SlotType
  self.PartData.CurrentLevel = GrowthProxy:GetGrowthLv(MyPlayerState, self.SlotType)
  self.PartData.TempCurrentLevel = GrowthProxy:GetGrowthTempLv(MyPlayerState, self.SlotType)
  self.PartData.MaxLevel = GrowthProxy:GetGrowthSlotLvMax(MyPlayerState.SelectRoleId, self.SlotType)
  self.PartData.OldSingleSelect = self.PartData.SingleSelect
  self.PartData.SingleSelect = GrowthProxy:IsSingleSelect(MyPlayerState.SelectRoleId, self.SlotType)
  self.PartData.CurrentLevel = self.PartData.CurrentLevel and self.PartData.CurrentLevel or 0
  self.PartData.UpgradeCost = GrowthProxy:GetGrowthSlotCost(MyPlayerState.SelectRoleId, self.SlotType, self.Lv)
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
  local Desc = ""
  if self.PartData.bSkillSlot or self.PartData.SlotType == UE4.EGrowthSlotType.Survive or self.PartData.SlotType == UE4.EGrowthSlotType.Shield then
    Desc = self.PartData.SkillRow["Intro" .. self.Lv]
  else
    Desc = GrowthProxy:GetGrowthItemDesc(MyPlayerState.SelectRoleId, self.SlotType, self.Lv)
  end
  self.Text_Desc:SetText(Desc)
  local UpgradeCost = GrowthProxy:GetGrowthSlotCost(MyPlayerState.SelectRoleId, self.PartData.SlotType, self.Lv)
  self.Text_Cost:SetText(UpgradeCost)
end
function GrowthPartItemMobile:InitializeLuaEvent()
  GrowthPartItemMobile.super.InitializeLuaEvent(self)
  self.OnPartItemClicked = LuaEvent.new()
  self.OnRevertBtnClicked = LuaEvent.new()
end
function GrowthPartItemMobile:Construct()
  self.PMImg_Select.OnMouseButtonUpEvent:Bind(self, self.OnMouseClick)
  self.PMImg_Select.OnMouseEnterEvent:Bind(self, self.OnMouseCursorEnter)
  self.PMImg_Select.OnMouseLeaveEvent:Bind(self, self.OnMouseCursorLeave)
  self.Lv = 1
  self.bIsMouseHover = false
  GrowthPartItemMobile.super.Construct(self)
end
function GrowthPartItemMobile:Destruct()
  GrowthPartItemMobile.super.Destruct(self)
end
function GrowthPartItemMobile:OnMouseClick(Geometry, MouseEvent)
  if UE4.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent).KeyName == "LeftMouseButton" then
    self.OnPartItemClicked(self.SlotType, self.Lv)
  elseif UE4.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent).KeyName == "RightMouseButton" then
    self.OnRevertBtnClicked(self.SlotType, true)
  end
end
function GrowthPartItemMobile:OnMouseCursorEnter(MouseEvent)
  self.bIsMouseHover = true
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  GrowthProxy:SetSelectSlot(self.SlotType)
  GrowthProxy:SetSelectSlotLv(self.Lv)
  if self.PartState ~= GrowthDefine.PartState.Upgraded then
    self:UpdatePartState()
    self:K2_PostAkEvent(self.Ak_Operate:Find(AkOnMouseHovered))
    GameFacade:SendNotification(NotificationDefines.Growth.GrowthWeaponDetailUpdateCmd)
  end
end
function GrowthPartItemMobile:OnMouseCursorLeave(MouseEvent)
  self.bIsMouseHover = false
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  GrowthProxy:SetSelectSlot(UE4.EGrowthSlotType.Max)
  GrowthProxy:SetSelectSlotLv(0)
  if self.PartState ~= GrowthDefine.PartState.Upgraded then
    self:UpdatePartState()
  end
  GameFacade:SendNotification(NotificationDefines.Growth.GrowthWeaponDetailUpdateCmd)
end
function GrowthPartItemMobile:UpdatePartState()
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
  local bUpgraded = self.PartData.CurrentLevel >= self.Lv
  if self.PartData.SingleSelect then
    bUpgraded = self.PartData.CurrentLevel == self.Lv
  end
  if bUpgraded then
    self.PartState = GrowthDefine.PartState.Upgraded
  elseif bMaxLevel then
    self.PartState = GrowthDefine.PartState.CannotUpgradeMaxLv
  else
    if self.PartData.GrowthPoint >= self.PartData.UpgradeCost then
      self.PartState = GrowthDefine.PartState.Upgradeable
    else
      self.PartState = GrowthDefine.PartState.CannotUpgradePointNotEnough
    end
    if GameState:GetModeType() == UE4.EPMGameModeType.Bomb and GameState:GetRoundState() ~= UE4.ERoundStage.Freeze then
      self.PartState = GrowthDefine.PartState.CannotUpgradeRoundState
    end
  end
  self:OnUpdatePartState()
end
function GrowthPartItemMobile:OnUpdatePartState()
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  if GrowthProxy:IsGrowthPartUpgradeManual(self) then
    self.Switch_Cost:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Switch_Cost:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.Switch_Cost:SetActiveWidgetIndex(0)
  self.Img_GrowthPoint:SetColorAndOpacity(self.GrowthPointColorNormal)
  if self.PartState == GrowthDefine.PartState.Upgradeable then
    self.Switch_Bg:SetActiveWidgetIndex(1)
    self.Text_Desc:SetColorAndOpacity(self.DescColorUpgradeable)
    self.Text_Cost:SetColorAndOpacity(self.CostColorUpgradeable)
  elseif self.PartState == GrowthDefine.PartState.CannotUpgradePointNotEnough then
    self.Switch_Bg:SetActiveWidgetIndex(0)
    self.Text_Desc:SetColorAndOpacity(self.DescColorCannotUpgrade)
    self.Text_Cost:SetColorAndOpacity(self.CostColorCannotUpgrade)
  elseif self.PartState == GrowthDefine.PartState.CannotUpgradeMaxLv then
    self.Switch_Bg:SetActiveWidgetIndex(0)
    self.Text_Desc:SetColorAndOpacity(self.DescColorCannotUpgradeMaxLv)
    if self.PartData.GrowthPoint >= self.PartData.UpgradeCost then
      self.Text_Cost:SetColorAndOpacity(self.CostColorMaxLvCanChange)
    else
      self.Text_Cost:SetColorAndOpacity(self.CostColorMaxLvCannotChange)
    end
    self.Img_GrowthPoint:SetColorAndOpacity(self.GrowthPointColorUpgradeMaxLv)
  elseif self.PartState == GrowthDefine.PartState.CannotUpgradeRoundState then
    self.Switch_Bg:SetActiveWidgetIndex(0)
    self.Text_Desc:SetColorAndOpacity(self.DescColorCannotUpgradeMaxLv)
    if self.PartData.GrowthPoint >= self.PartData.UpgradeCost then
      self.Text_Cost:SetColorAndOpacity(self.CostColorMaxLvCanChange)
    else
      self.Text_Cost:SetColorAndOpacity(self.CostColorMaxLvCannotChange)
    end
    self.Img_GrowthPoint:SetColorAndOpacity(self.GrowthPointColorUpgradeMaxLv)
  elseif self.PartState == GrowthDefine.PartState.Upgraded then
    self.Switch_Bg:SetActiveWidgetIndex(2)
    self.Switch_Cost:SetActiveWidgetIndex(1)
    self.Text_Desc:SetColorAndOpacity(self.DescColorUpgraded)
    self.Text_Cost:SetColorAndOpacity(self.CostColorUpgraded)
  end
  if self.Switch_Type then
    if self.PartState == GrowthDefine.PartState.Upgraded then
      if self.SlotType == UE4.EGrowthSlotType.QSkill or self.SlotType == UE4.EGrowthSlotType.PassiveSkill then
        self.Switch_Type:SetActiveWidgetIndex(1)
      elseif self.SlotType == UE4.EGrowthSlotType.Survive or self.SlotType == UE4.EGrowthSlotType.Shield then
        self.Switch_Type:SetActiveWidgetIndex(2)
      else
        self.Switch_Type:SetActiveWidgetIndex(3)
      end
    else
      self.Switch_Type:SetActiveWidgetIndex(0)
    end
  end
end
return GrowthPartItemMobile
