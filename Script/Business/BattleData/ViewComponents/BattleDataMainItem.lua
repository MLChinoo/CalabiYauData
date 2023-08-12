local BattleDataMainItem = class("BattleDataMainItem", PureMVC.ViewComponentPanel)
local WidgetIndex = {
  Default = 0,
  DangerZone = 1,
  C4 = 2,
  Falling = 3
}
local Valid
function BattleDataMainItem:Construct()
  BattleDataMainItem.super.Construct(self)
  Valid = self.HitNumSwitcher and self.HitNumSwitcher:SetActiveWidgetIndex(0)
  Valid = self.Button and self.Button.OnHovered:Add(self, self.OnHoveredButton)
  Valid = self.Button and self.Button.OnUnhovered:Add(self, self.OnUnHoveredButton)
  Valid = self.MenuAnchor_SecondaryItemMenu and self.MenuAnchor_SecondaryItemMenu.OnGetMenuContentEvent:Bind(self, self.OnGetContentEvent)
end
function BattleDataMainItem:Destruct()
  Valid = self.Button and self.Button.OnHovered:Remove(self, self.OnHoveredButton)
  Valid = self.Button and self.Button.OnUnhovered:Remove(self, self.OnUnHoveredButton)
  Valid = self.MenuAnchor_SecondaryItemMenu and self.MenuAnchor_SecondaryItemMenu.OnGetMenuContentEvent:Unbind()
  BattleDataMainItem.super.Destruct(self)
end
function BattleDataMainItem:Init(BattleDataInfo)
  if nil == BattleDataInfo then
    return
  end
  local WeaponTypeIndex = WidgetIndex.Default
  if BattleDataInfo.DamageOriginType == UE4.ECyDamageOriginType.Weapon then
    if BattleDataInfo.PlayerWeaponType == UE4.ECyPlayerWeaponType.C4 then
      WeaponTypeIndex = WidgetIndex.C4
    end
  elseif BattleDataInfo.DamageOriginType == UE4.ECyDamageOriginType.System then
    if BattleDataInfo.SystemWeaponType == UE4.ECySystemWeaponType.DangerZone or BattleDataInfo.SystemWeaponType == UE4.ECySystemWeaponType.DeathZone then
      WeaponTypeIndex = WidgetIndex.DangerZone
    elseif BattleDataInfo.SystemWeaponType == UE4.ECySystemWeaponType.Fall then
      WeaponTypeIndex = WidgetIndex.Falling
    end
  end
  Valid = self.Img_WeaponSource and BattleDataInfo.WeaponImage and self:SetImageByPaperSprite_MatchSize(self.Img_WeaponSource, BattleDataInfo.WeaponImage)
  Valid = self.WeaponIconTypeSwitcher and self.WeaponIconTypeSwitcher:SetActiveWidgetIndex(WeaponTypeIndex)
  Valid = self.Img_EnemyAvatar and self:SetImageByTexture2D(self.Img_EnemyAvatar, BattleDataInfo.EnemyAvatar)
  Valid = self.Img_PlayerAvatar and self:SetImageByTexture2D(self.Img_PlayerAvatar, BattleDataInfo.PlayerAvatar)
  Valid = self.Text_DamageFromName and self.Text_DamageFromName:SetText(BattleDataInfo.DamagerName)
  local NameColor = self.NameColor_Yellow
  local BackgroundColor = self.BackgroundColor_Yellow
  if BattleDataInfo.DamagerType == UE4.ECyBattleReportDamageRelation.Enemy then
    NameColor = self.NameColor_Red
    BackgroundColor = self.BackgroundColor_Red
  elseif BattleDataInfo.DamagerType == UE4.ECyBattleReportDamageRelation.Teammate then
    NameColor = self.NameColor_Blue
    BackgroundColor = self.BackgroundColor_Blue
  end
  Valid = self.Text_DamageFromName and self.Text_DamageFromName:SetColorAndOpacity(NameColor)
  Valid = self.Img_Background and self.Img_Background:SetBrushTintColor(BackgroundColor)
  Valid = self.Overlay_KillSign and self.Overlay_KillSign:SetVisibility(BattleDataInfo.PlayerIsDead and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  Valid = self.Text_KillTip and self.Text_KillTip:SetVisibility(BattleDataInfo.PlayerIsDead and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  Valid = self.Overlay_PlayerAvatar and self.Overlay_PlayerAvatar:SetRenderOpacity(BattleDataInfo.PlayerIsDead and 0.5 or 1)
  Valid = self.Text_HitHeadNum and self.Text_HitHeadNum:SetText(BattleDataInfo.bHitBodyPartsWeapon and BattleDataInfo.HitNumsOfHead or 0)
  Valid = self.Text_HitBodyNum and self.Text_HitBodyNum:SetText(BattleDataInfo.bHitBodyPartsWeapon and BattleDataInfo.HitNumsOfBody or 0)
  Valid = self.Text_HitFootNum and self.Text_HitFootNum:SetText(BattleDataInfo.bHitBodyPartsWeapon and BattleDataInfo.HitNumsOfFoot or 0)
  Valid = self.Text_TotalDamage and self.Text_TotalDamage:SetText(BattleDataInfo.TotalDamage)
  self.SecondaryList = BattleDataInfo.SecondaryList
end
function BattleDataMainItem:OnHoveredButton()
  Valid = self.MenuAnchor_SecondaryItemMenu and self.MenuAnchor_SecondaryItemMenu:Open()
  GameFacade:SendNotification(NotificationDefines.BattleData.CleanAutoCollapsedTimer)
end
function BattleDataMainItem:OnUnHoveredButton()
  Valid = self.MenuAnchor_SecondaryItemMenu and self.MenuAnchor_SecondaryItemMenu:Close()
end
function BattleDataMainItem:OnGetContentEvent()
  local SecondaryPanelClass = self.MenuAnchor_SecondaryItemMenu and self.MenuAnchor_SecondaryItemMenu.MenuClass
  local SecondaryPanel = SecondaryPanelClass and UE4.UWidgetBlueprintLibrary.Create(self, SecondaryPanelClass)
  Valid = SecondaryPanel and SecondaryPanel:Init(self.SecondaryList)
  return SecondaryPanel
end
return BattleDataMainItem
