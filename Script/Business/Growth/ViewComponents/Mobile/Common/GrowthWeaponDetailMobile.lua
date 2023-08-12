local GrowthWeaponDetailMobile = class("GrowthWeaponDetailMobile", PureMVC.ViewComponentPanel)
local GrowthWeaponDetailMediator = require("Business/Growth/Mediators/GrowthWeaponDetailMediator")
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
local GrowthDefine = require("Business/Growth/Proxies/GrowthDefine")
function GrowthWeaponDetailMobile:ListNeededMediators()
  return {GrowthWeaponDetailMediator}
end
function GrowthWeaponDetailMobile:OnInitialized()
  GrowthWeaponDetailMobile.super.OnInitialized(self)
end
function GrowthWeaponDetailMobile:InitializeLuaEvent()
  GrowthWeaponDetailMobile.super.InitializeLuaEvent(self)
end
function GrowthWeaponDetailMobile:Construct()
  GrowthWeaponDetailMobile.super.Construct(self)
end
function GrowthWeaponDetailMobile:Destruct()
  GrowthWeaponDetailMobile.super.Destruct(self)
end
function GrowthWeaponDetailMobile:Update(GrowthDetailData)
  self.GrowthDetailData = GrowthDetailData
  self.SlotType = GrowthDetailData.SlotType
  self.BP_LevelInfo_ShootSpeed:SetLevelProgressInfo(GrowthDetailData[GrowthDefine.PropertyNames1.ShootSpeed])
  self.BP_LevelInfo_Scattering:SetLevelProgressInfo(GrowthDetailData[GrowthDefine.PropertyNames1.Scattering])
  self.BP_LevelInfo_AimSpeed:SetLevelProgressInfo(GrowthDetailData[GrowthDefine.PropertyNames1.AimSpeed])
  self.BP_LevelInfo_GunRecoil:SetLevelProgressInfo(GrowthDetailData[GrowthDefine.PropertyNames1.GunRecoil])
  self.BP_LevelInfo_MagazineCapacity:SetLevelProgressInfo(GrowthDetailData[GrowthDefine.PropertyNames1.MagazineCapacity])
  self.BP_LevelInfo_ReloadSpeed:SetLevelProgressInfo(GrowthDetailData[GrowthDefine.PropertyNames1.ReloadSpeed])
  self.BP_LevelInfo_MoveSpeed:SetLevelProgressInfo(GrowthDetailData[GrowthDefine.PropertyNames1.MoveSpeed])
  self.BP_LevelInfo_PullBoltSpeed:SetLevelProgressInfo(GrowthDetailData[GrowthDefine.PropertyNames1.PullBoltSpeed])
  self.BP_LevelInfo_Change2DHurt:SetLevelProgressInfo(GrowthDetailData[GrowthDefine.PropertyNames1.Change2DHurt])
  for Index = 1, table.count(GrowthDetailData.DamageInfos) do
    self["BP_DamageInfo_" .. Index - 1]:SetLevelInfo(GrowthDetailData.DamageInfos[Index])
  end
  self:UpdateAssistShoot()
end
function GrowthWeaponDetailMobile:UpdateAssistShoot()
  local idx = 1
  for key, PropertyName in ipairs(GrowthDefine.PropertyNames3) do
    if self.GrowthDetailData[PropertyName] and self.GrowthDetailData[PropertyName].InBaseNum > 0 then
      local Items = self.VB_AssistShootInfo:GetAllChildren()
      if idx > Items:Length() then
        GamePlayGlobal:CreateWidget(self, self.WBP_ExtraInfoClass, 1, function(Item)
          if Item then
            self.VB_AssistShootInfo:AddChild(Item)
            self:SetAssistShootItem(Item, key, PropertyName)
            if idx > 1 then
              local margin = UE4.FMargin()
              margin.Top = 25
              Item.Slot:SetPadding(margin)
            end
          end
        end)
      else
        local Item = Items:Get(idx)
        Item:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self:SetAssistShootItem(Item, key, PropertyName)
        if idx > 1 then
          local margin = UE4.FMargin()
          margin.Top = 25
          Item.Slot:SetPadding(margin)
        end
      end
      idx = idx + 1
    end
  end
  local Items = self.VB_AssistShootInfo:GetAllChildren()
  for i = idx, Items:Length() do
    local Item = Items:Get(i)
    Item:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function GrowthWeaponDetailMobile:SetAssistShootItem(Item, key, PropertyName)
  Item.Text_Title:SetText(string.format("%s：", PropertyName))
  local info = self.GrowthDetailData[PropertyName]
  Item.TextBlock_Num:SetText(string.format("%s%s", info.InNum, GrowthDefine.PropertySymbol3[key]))
  if info.InBaseNum and info.InBaseNum ~= info.InNum then
    Item.TextBlock_Num:SetColorAndOpacity(Item.OriginColorUpgrade)
  else
    Item.TextBlock_Num:SetColorAndOpacity(Item.OriginColorUnUpgrade)
  end
  Item.TextBlock_NextLevelNum:SetText(string.format("%s%s", info.InNextLevelNum, GrowthDefine.PropertySymbol3[key]))
  if info.InNextLevelNum > info.InNum then
    Item.TextBlock_NextLevelNum:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    Item.Img_Arrow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    Item.TextBlock_NextLevelNum:SetColorAndOpacity(Item.ColorUpgrade)
    Item.Img_Arrow:SetColorAndOpacity(Item.ArrowUpgrade)
  elseif info.InNextLevelNum < info.InNum then
    Item.TextBlock_NextLevelNum:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    Item.Img_Arrow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    Item.TextBlock_NextLevelNum:SetColorAndOpacity(Item.ColorDownUpgrade)
    Item.Img_Arrow:SetColorAndOpacity(Item.ArrowDownUpgrade)
  else
    Item.TextBlock_NextLevelNum:SetVisibility(UE4.ESlateVisibility.Collapsed)
    Item.Img_Arrow:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function GrowthWeaponDetailMobile:UpdateGunFeature()
  local InfoLen = self.GrowthDetailData.GunFeature:Length()
  for i = 1, InfoLen do
    local Items = self.VB_GunFeatureInfo:GetAllChildren()
    if i > Items:Length() then
      GamePlayGlobal:CreateWidget(self, self.WBP_ExtraInfoClass, 1, function(Item)
        if Item then
          self.VB_GunFeatureInfo:AddChild(Item)
          Item.Text_Info:SetText(self.GrowthDetailData.GunFeature:Get(i))
          if i > 1 then
            local margin = UE4.FMargin()
            margin.Top = 5
            Item.Slot:SetPadding(margin)
          end
        end
      end)
    else
      local Item = Items:Get(i)
      Item:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      Item.Text_Info:SetText(self.GrowthDetailData.GunFeature:Get(i))
      if i > 1 then
        local margin = UE4.FMargin()
        margin.Top = 5
        Item.Slot:SetPadding(margin)
      end
    end
  end
  local Items = self.VB_GunFeatureInfo:GetAllChildren()
  for i = InfoLen + 1, Items:Length() do
    local Item = Items:Get(i)
    Item:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
return GrowthWeaponDetailMobile
