local ApartmentPromiseGridItem = class("ApartmentPromiseGridItem", PureMVC.ViewComponentPanel)
local Valid
local ApartmentPromiseGridItemMediator = require("Business/Apartment/Mediators/ApartmentPromiseGridItemMediator")
function ApartmentPromiseGridItem:ListNeededMediators()
  return {ApartmentPromiseGridItemMediator}
end
function ApartmentPromiseGridItem:Init(Index, Data)
  self.Index = Index
  self.ItemId = Data.ItemId
  self.ItemArray = Data.ItemArray
  self.ItemTypeName = Data.ItemTypeName
  self.bIsPromiseTask = Data.bIsPromise
  self.ItemDesc = Data.ItemDesc
  self.TaskProgress = Data.TaskProgress
  self.TaskId = Data.TaskId
  self.AVGEventId = Data.AVGEventId
  self.Level = Data.Level
  self.bIsGet = Data.bIsGet
  self.bIsShowRewardTip = Data.bIsShowRewardTip
  self.bIsUnlock = Data.bIsUnlock
  self.ProgressLevel = Data.ProgressLevel
  Valid = (not Data.bIsUnlock or Data.bIsGet) and self:StopAllAnimations()
  if Data.bIsPromise then
    Valid = self.SizeBox_RewardTip and self.SizeBox_RewardTip:SetVisibility(Data.bIsUnlock and Data.bIsShowRewardTip and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
  else
    Valid = self.SizeBox_RewardTip and self.SizeBox_RewardTip:SetVisibility(not (not Data.bIsUnlock or Data.bIsGet) and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
  end
  Valid = self.SizeBox_SpecialEffect and self.SizeBox_SpecialEffect:SetVisibility(Data.bIsPromise and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
  Valid = self.PromiseAvailable and self:PlayAnimation(self.PromiseAvailable, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
  if self.ItemArray and self.ItemArray:Length() > 1 then
    Valid = self.Image_Item and Data.ItemArrayImg and self:SetImageByTexture2D(self.Image_Item, Data.ItemArrayImg)
  else
    Valid = self.Image_Item and Data.ItemsoftTexture and self:SetImageByTexture2D(self.Image_Item, Data.ItemsoftTexture)
  end
  Valid = self.WidgetSwitcher_Bg and self.WidgetSwitcher_Bg:SetActiveWidgetIndex(Data.bIsPromise and (Data.bIsUnlock and (Data.bIsGet and 4 or 0) or 3) or Data.bIsGet and 2 or 1)
  Valid = Data.bIsPromise and Data.bIsUnlock and self.WidgetSwitcher_FinishOrIng and self.WidgetSwitcher_FinishOrIng:SetActiveWidgetIndex(Data.bIsGet and 0 or 1)
  Valid = Data.bIsPromise and Data.bIsUnlock and self.WidgetSwitcher_Finish and self.WidgetSwitcher_Finish:SetActiveWidgetIndex(Data.ProgressLevel >= 1 and 1 or 0)
  Valid = self.WidgetSwitcher_TaskOrLevel and self.WidgetSwitcher_TaskOrLevel:SetActiveWidgetIndex(Data.bIsPromise and 1 or 0)
  Valid = self.ProgressBar_Task and self.ProgressBar_Task:SetPercent(Data.ProgressLevel or 0)
  Valid = self.Image_Got and self.Image_Got:SetVisibility(Data.bIsGet and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
  Valid = self.Image_Quality and self.Image_Quality:SetColorAndOpacity(Data.ItemQualityColor)
  Valid = self.Image_Got_Override and self.Image_Got_Override:SetVisibility(Data.bIsGet and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
  Valid = self.TextBlock_Level and self.TextBlock_Level:SetText(Data.Level)
  if self.ItemArray and self.ItemArray:Length() > 1 and not Data.bIsPromise then
    Valid = self.TextBlock_Money and self.TextBlock_Money:SetVisibility(self.ItemArray:Length() > 1 and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
    Valid = Data.ItemAmount and self.TextBlock_Money and self.TextBlock_Money:SetText(self.ItemArray:Length())
  else
    Valid = self.TextBlock_Money and self.TextBlock_Money:SetVisibility(Data.ItemAmount > 1 and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
    Valid = Data.ItemAmount and self.TextBlock_Money and self.TextBlock_Money:SetText(Data.ItemAmount)
  end
  Valid = self.Button_Clicked and self.Button_Clicked:SetIsEnabled(true)
end
function ApartmentPromiseGridItem:InitializeLuaEvent()
  self.actionOnClickButton = LuaEvent.new()
end
function ApartmentPromiseGridItem:Construct()
  ApartmentPromiseGridItem.super.Construct(self)
  Valid = self.Button_Clicked and self.Button_Clicked.OnClicked:Add(self, self.OnClickButton)
end
function ApartmentPromiseGridItem:Destruct()
  Valid = self.Button_Clicked and self.Button_Clicked.OnClicked:Remove(self, self.OnClickButton)
  ApartmentPromiseGridItem.super.Destruct(self)
end
function ApartmentPromiseGridItem:OnClickButton()
  self.actionOnClickButton(self)
end
function ApartmentPromiseGridItem:SetIsClicked()
  self:StopAllAnimations()
  self.bIsGet = true
  Valid = self.SizeBox_RewardTip and self.SizeBox_RewardTip:SetVisibility(UE.ESlateVisibility.Collapsed)
  Valid = self.WidgetSwitcher_Bg and self.WidgetSwitcher_Bg:SetActiveWidgetIndex(self.bIsPromiseTask and 4 or 2)
  Valid = self.WidgetSwitcher_FinishOrIng and self.WidgetSwitcher_FinishOrIng:SetActiveWidgetIndex(0)
  Valid = self.WidgetSwitcher_Finish and self.WidgetSwitcher_Finish:SetActiveWidgetIndex(1)
  Valid = self.Image_Got and self.Image_Got:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  Valid = self.Image_Got_Override and self.Image_Got_Override:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
return ApartmentPromiseGridItem
