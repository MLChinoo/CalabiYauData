local RoleAchvRoleHeadItem = class("RoleAchvRoleHeadItem", PureMVC.ViewComponentPanel)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
function RoleAchvRoleHeadItem:InitializeLuaEvent()
end
function RoleAchvRoleHeadItem:Construct()
  LogDebug("RoleAchvRoleHeadItem", "Panel construct")
  self.super.Construct(self)
end
function RoleAchvRoleHeadItem:Destruct()
  self.super.Destruct(self)
  if self.redDotName then
    RedDotTree:Unbind(self.redDotName)
  end
end
function RoleAchvRoleHeadItem:InitItem(idx, roleAchvData)
  self.Idx = idx
  self.RoleAchvData = roleAchvData
  self.ImgSelectBg:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ImgGenNormal:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if roleAchvData.RoleHeadTexture then
    self.imgHero:SetBrushFromSoftTexture(roleAchvData.RoleHeadTexture)
  else
    self.CanvasHead:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ImgGenNormal:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if roleAchvData.ItemType == CareerEnumDefine.RoleAchvHeadItemType.Hero then
    self.TxtHeroName:SetText(roleAchvData.RoleProfileCfg.NameCn)
  end
  local totalNum = 0
  local ownedLvNum = 0
  for beginId, info in pairs(roleAchvData.RoleAchvInfo or {}) do
    totalNum = totalNum + table.count(info.levelNodes)
    ownedLvNum = ownedLvNum + info.level
  end
  local achvPct = ownedLvNum / totalNum
  self.ProgressBarAchv:SetPercent(achvPct)
  self.PMBtnSelected.OnClicked:Add(self, self.OnItemClicked)
  self:UpdateRedDot()
end
function RoleAchvRoleHeadItem:OnItemClicked()
  self.ImgSelectBg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  GameFacade:SendNotification(NotificationDefines.Career.RoleAchievement.HeadItemSelected, self.Idx)
end
function RoleAchvRoleHeadItem:SetNotBeSelected()
  self.ImgSelectBg:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function RoleAchvRoleHeadItem:UpdateRedDot()
  self.RodDotAchvNum = 0
  for beginId, info in pairs(self.RoleAchvData.RoleAchvInfo or {}) do
    if info.redDotId then
      self.RodDotAchvNum = self.RodDotAchvNum + 1
    end
  end
  self.RedDot_New:SetVisibility(self.RodDotAchvNum > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
return RoleAchvRoleHeadItem
