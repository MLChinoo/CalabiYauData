local BattleDataSecondaryItem = class("BattleDataSecondaryItem", PureMVC.ViewComponentPanel)
local WidgetIndex = {
  Default = 0,
  DangerZone = 1,
  C4 = 2,
  Falling = 3
}
local Valid
function BattleDataSecondaryItem:Construct()
  BattleDataSecondaryItem.super.Construct(self)
end
function BattleDataSecondaryItem:Destruct()
  BattleDataSecondaryItem.super.Destruct(self)
end
function BattleDataSecondaryItem:Init(SecondaryInfo)
  local WeaponTypeIndex = WidgetIndex.Default
  if SecondaryInfo.DamageOriginType == UE4.ECyDamageOriginType.Weapon then
    if SecondaryInfo.PlayerWeaponType == UE4.ECyPlayerWeaponType.C4 then
      WeaponTypeIndex = WidgetIndex.C4
    end
  elseif SecondaryInfo.DamageOriginType == UE4.ECyDamageOriginType.System then
    if SecondaryInfo.SystemWeaponType == UE4.ECySystemWeaponType.DangerZone or SecondaryInfo.SystemWeaponType == UE4.ECySystemWeaponType.DeathZone then
      WeaponTypeIndex = WidgetIndex.DangerZone
    elseif SecondaryInfo.SystemWeaponType == UE4.ECySystemWeaponType.Fall then
      WeaponTypeIndex = WidgetIndex.Falling
    end
  end
  Valid = self.Img_WeaponSource and SecondaryInfo.WeaponImage and self:SetImageByPaperSprite_MatchSize(self.Img_WeaponSource, SecondaryInfo.WeaponImage)
  Valid = self.WeaponIconTypeSwitcher and self.WeaponIconTypeSwitcher:SetActiveWidgetIndex(WeaponTypeIndex)
  Valid = self.HitNumSwitcher and self.HitNumSwitcher:SetActiveWidgetIndex(SecondaryInfo.bHitBodyPartsWeapon and 0 or 1)
  Valid = self.Text_HitHeadNum and self.Text_HitHeadNum:SetText(SecondaryInfo.HitNumsOfHead or 0)
  Valid = self.Text_HitBodyNum and self.Text_HitBodyNum:SetText(SecondaryInfo.HitNumsOfBody or 0)
  Valid = self.Text_HitFootNum and self.Text_HitFootNum:SetText(SecondaryInfo.HitNumsOfFoot or 0)
  Valid = self.Text_TotalDamage and self.Text_TotalDamage:SetText(SecondaryInfo.TotalDamage or 0)
  Valid = self.Text_HitTotalNum and self.Text_HitTotalNum:SetText(SecondaryInfo.TotalHitNums or 0)
end
return BattleDataSecondaryItem
