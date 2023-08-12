local AchievementCategoryPanel = class("AchievementCategoryPanel", PureMVC.ViewComponentPanel)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
function AchievementCategoryPanel:InitializeLuaEvent()
end
function AchievementCategoryPanel:Construct()
  LogDebug("AchievementCategoryPanel", "Panel construct")
  AchievementCategoryPanel.super.Construct(self)
  if self.Button_Item then
    self.Button_Item.OnClicked:Add(self, self.OnChooseAchievementType)
  end
  if self.Button_Item_1 then
    self.Button_Item_1.OnClicked:Add(self, self.OnChooseAchievementType)
  end
  if self.Button_Item_2 then
    self.Button_Item_2.OnClicked:Add(self, self.OnChooseAchievementType)
  end
  if self.Button_Item_3 then
    self.Button_Item_3.OnClicked:Add(self, self.OnChooseAchievementType)
  end
end
function AchievementCategoryPanel:Destruct()
  if self.Button_Item then
    self.Button_Item.OnClicked:Remove(self, self.OnChooseAchievementType)
  end
  if self.Button_Item_1 then
    self.Button_Item_1.OnClicked:Remove(self, self.OnChooseAchievementType)
  end
  if self.Button_Item_2 then
    self.Button_Item_2.OnClicked:Remove(self, self.OnChooseAchievementType)
  end
  if self.Button_Item_3 then
    self.Button_Item_3.OnClicked:Add(self, self.OnChooseAchievementType)
  end
  if self.redDotName then
    RedDotTree:Unbind(self.redDotName)
  end
  AchievementCategoryPanel.super.Destruct(self)
end
function AchievementCategoryPanel:GenerateAchievementItem(itemList)
  if itemList and self.DynamicEntryBox_Achievement then
    for key, value in pairsByKeys(itemList) do
      if self.panelAchievementType == CareerEnumDefine.achievementType.glory then
        if value.level > 0 then
          local itemIns = self.DynamicEntryBox_Achievement:BP_CreateEntry()
          itemIns:InitNormalItem(value)
        end
      else
        local itemIns = self.DynamicEntryBox_Achievement:BP_CreateEntry()
        itemIns:InitNormalItem(value)
      end
    end
  end
end
function AchievementCategoryPanel:InitAchievementPanel(inAchievementType, achievementPropTable)
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
  if self.ProgressBar_LevelProgress then
    local curLevel = achievementPropTable.level
    local progressPercent = 0
    if 5 == curLevel then
      progressPercent = 1
    else
      local acquiredNumOfMedals = achievementPropTable.GotNum
      local requiredNumList = {}
      for key, value in pairs(achievementPropTable.config) do
        requiredNumList[key] = value.Need
      end
      progressPercent = (acquiredNumOfMedals - requiredNumList[curLevel]) / (requiredNumList[curLevel + 1] - requiredNumList[curLevel])
    end
    self.ProgressBar_LevelProgress:SetPercent(progressPercent)
  end
  if self.DynamicEntryBox_Achievement then
    local canvasSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.DynamicEntryBox_Achievement)
    local slotSize = canvasSlot:GetSize()
    local achiveNum = table.count(achievementPropTable.achievementList)
    slotSize.Y = math.ceil(achiveNum / self.ItemNumInLine) * 149 - 9 + 23
    canvasSlot:SetSize(slotSize)
    self:GenerateAchievementItem(achievementPropTable.achievementList)
  end
  if self.panelAchievementType == CareerEnumDefine.achievementType.combat then
    self:OnChooseAchievementType()
  end
  local redDotName = ""
  if inAchievementType == CareerEnumDefine.achievementType.combat then
    redDotName = RedDotModuleDef.ModuleName.CareerAchieveCombat
  elseif inAchievementType == CareerEnumDefine.achievementType.hornor then
    redDotName = RedDotModuleDef.ModuleName.CareerAchieveHornor
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
function AchievementCategoryPanel:OnChooseAchievementType()
  LogDebug("AchievementCategoryPanel", "On Choose achievement type: " .. self.panelAchievementType)
  GameFacade:SendNotification(NotificationDefines.Career.Achievement.ShowAchievementTipCmd, self.panelAchievementType)
end
function AchievementCategoryPanel:UpdateRedDotAchieve(cnt)
  if self.RedDot_Achieve then
    self.RedDot_Achieve:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
return AchievementCategoryPanel
