local SeasonPrizeItem = class("SeasonPrizeItem", PureMVC.ViewComponentPanel)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
function SeasonPrizeItem:ListNeededMediators()
  return {}
end
function SeasonPrizeItem:InitView(itemInfo, isBest)
  self.prizeCfg = itemInfo.config
  if self.Image_Item then
    self:SetImageByTexture2D(self.Image_Item, self.prizeCfg.IconDivisionReward)
  end
  if self.Text_ItemName then
    self.Text_ItemName:SetText(self.prizeCfg.Title)
  end
  local prizeQualityCfg = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemQualityConfig(self.prizeCfg.Quality)
  if self.Image_Quality then
    self.Image_Quality:SetColorandOpacity(UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(prizeQualityCfg.color)))
  end
  if self.RichText_Condition then
    self.RichText_Condition:SetText(self.prizeCfg.ConditionDesc)
  end
  self:SetPrizeState(itemInfo.status)
end
function SeasonPrizeItem:SetPrizeState(newState)
  self.prizeStatus = newState
  if self.WidgetSwitcher_PrizeState then
    if self.prizeStatus == CareerEnumDefine.rewardStatus.locked then
      self.WidgetSwitcher_PrizeState:SetActiveWidgetIndex(0)
    end
    if self.prizeStatus == CareerEnumDefine.rewardStatus.unlocked then
      local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
      if platform == GlobalEnumDefine.EPlatformType.Mobile then
        self.WidgetSwitcher_PrizeState:SetActiveWidgetIndex(2)
      else
        self.WidgetSwitcher_PrizeState:SetActiveWidgetIndex(1)
      end
    end
    if self.prizeStatus == CareerEnumDefine.rewardStatus.hasAcquired then
      self.WidgetSwitcher_PrizeState:SetActiveWidgetIndex(3)
    end
  end
end
function SeasonPrizeItem:Construct()
  SeasonPrizeItem.super.Construct(self)
  if self.Button_Bottom then
    self.Button_Bottom.OnClicked:Add(self, self.ShowPrize)
  end
  if self.Button_Image then
    self.Button_Image.OnClicked:Add(self, self.ShowPrize)
  end
end
function SeasonPrizeItem:Destruct()
  if self.Button_Bottom then
    self.Button_Bottom.OnClicked:Remove(self, self.ShowPrize)
  end
  if self.Button_Image then
    self.Button_Image.OnClicked:Remove(self, self.ShowPrize)
  end
  SeasonPrizeItem.super.Destruct(self)
end
function SeasonPrizeItem:ShowPrize()
  local openData = {
    prizeCfg = self.prizeCfg,
    status = self.prizeStatus
  }
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.Mobile then
    ViewMgr:PushPage(self, UIPageNameDefine.CareerPrizeDisplay, openData, false)
  else
    ViewMgr:OpenPage(self, UIPageNameDefine.CareerPrizeDisplay, false, openData)
  end
end
return SeasonPrizeItem
