local AchievementCategoryPanelMobile = class("AchievementCategoryPanelMobile", PureMVC.ViewComponentPanel)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
function AchievementCategoryPanelMobile:InitializeLuaEvent()
end
function AchievementCategoryPanelMobile:Construct()
  LogDebug("AchievementCategoryPanelMobile", "Panel construct")
  AchievementCategoryPanelMobile.super.Construct(self)
  if self.Button_Item then
    self.Button_Item.OnClicked:Add(self, self.OnChooseAchievementType)
  end
  if self.Button_Item_1 then
    self.Button_Item_1.OnClicked:Add(self, self.OnChooseAchievementType)
  end
  if self.Button_Item_2 then
    self.Button_Item_2.OnClicked:Add(self, self.OnChooseAchievementType)
  end
end
function AchievementCategoryPanelMobile:Destruct()
  if self.Button_Item then
    self.Button_Item.OnClicked:Remove(self, self.OnChooseAchievementType)
  end
  if self.Button_Item_1 then
    self.Button_Item_1.OnClicked:Remove(self, self.OnChooseAchievementType)
  end
  if self.Button_Item_2 then
    self.Button_Item_2.OnClicked:Remove(self, self.OnChooseAchievementType)
  end
  if self.redDotName then
    RedDotTree:Unbind(self.redDotName)
  end
  AchievementCategoryPanelMobile.super.Destruct(self)
end
function AchievementCategoryPanelMobile:GenerateAchievementItem(itemList)
  if itemList and self.DynamicEntryBox_Achievement then
    for key, value in pairsByKeys(itemList) do
      local itemIns = self.DynamicEntryBox_Achievement:BP_CreateEntry()
      if self.panelAchievementType == CareerEnumDefine.achievementType.glory then
        itemIns:InitGloryItem(value)
      else
        itemIns:InitNormalItem(value)
      end
    end
  end
end
function AchievementCategoryPanelMobile:InitAchievementPanel(inAchievementType, achievementPropTable)
  self.panelAchievementType = inAchievementType
  if self.WidgetSwitcher_ImageType then
    self.WidgetSwitcher_ImageType:SetActiveWidgetIndex(inAchievementType - 1)
  end
  if self.TextBlock_Level then
    self.TextBlock_Level:SetText(CareerEnumDefine.achievementLevel[achievementPropTable.level])
    if 5 == achievementPropTable.level then
      ObjectUtil:SetTextColor(self.TextBlock_Level, 0.51, 0.03, 0.04, 1.0)
    end
  end
  if self.TextBlock_Name and self.TextBlock_EnglishName then
    self.TextBlock_Name:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Career, CareerEnumDefine.achievementName[self.panelAchievementType]))
    self.TextBlock_EnglishName:SetText(CareerEnumDefine.achievementName[self.panelAchievementType] .. " Achievements")
  end
  if self.TextBlock_Owned and self.TextBlock_Total then
    local totalNumOfMedals = table.count(achievementPropTable.achievementList)
    local acquiredNumOfMedals = achievementPropTable.lightNum
    self.TextBlock_Owned:SetText(acquiredNumOfMedals)
    self.TextBlock_Total:SetText(totalNumOfMedals)
  end
  if self.DynamicEntryBox_Achievement then
    local canvasSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.DynamicEntryBox_Achievement)
    local slotSize = canvasSlot:GetSize()
    local achiveNum = table.count(achievementPropTable.achievementList)
    slotSize.Y = math.ceil(achiveNum / self.ItemNumInLine) * 189 - 9 + 20
    canvasSlot:SetSize(slotSize)
    self:GenerateAchievementItem(achievementPropTable.achievementList)
  end
  if self.panelAchievementType == CareerEnumDefine.achievementType.combat then
    self:OnChooseAchievementType()
  end
  local redDotName = ""
  if inAchievementType == CareerEnumDefine.achievementType.combat then
    redDotName = RedDotModuleDef.ModuleName.CareerAchieveCombat
  elseif inAchievementType == CareerEnumDefine.achievementType.glory then
    redDotName = RedDotModuleDef.ModuleName.CareerAchieveGlory
  end
  if "" ~= redDotName then
    self.redDotName = redDotName
    RedDotTree:Bind(self.redDotName, function(cnt)
      self:UpdateRedDotAchieve(cnt)
    end)
    self:UpdateRedDotAchieve(RedDotTree:GetRedDotCnt(self.redDotName))
  end
end
function AchievementCategoryPanelMobile:OnChooseAchievementType()
  LogDebug("AchievementCategoryPanelMobile", "On Choose achievement type: " .. self.panelAchievementType)
  GameFacade:SendNotification(NotificationDefines.Career.Achievement.ShowAchievementTipCmd, self.panelAchievementType)
end
function AchievementCategoryPanelMobile:UpdateRedDotAchieve(cnt)
  if self.RedDot_Achieve then
    self.RedDot_Achieve:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
return AchievementCategoryPanelMobile
